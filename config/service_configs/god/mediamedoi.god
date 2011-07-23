rails_root = "/Users/mint/Sites/mediamedoi/current"
rake = "/usr/local/rvm/wrappers/ruby-1.9.2-tv1_9_2_0/rake"

worker_groups = {
  "high priority" => {
    "name" => "mediamedoi-dj-high-%d",
    "group" => "mediamedoi-dj-high",
    "count" => 2,
    "MIN_PRIORITY" => "0",
    "SLEEP_DELAY" => "1"
  },
  "lower priority" => {
    "name" => "mediamedoi-dj-normal-%d",
    "group" => "mediamedoi-dj-normal",
    "count" => 2,
    "MAX_PRIORITY" => "1",
    "SLEEP_DELAY" => "5"
  }
}

worker_groups.each_pair do |label,options|
  name_format = options.delete("name")
  group = options.delete("group")
  count = options.delete("count")
  env_vars = options

  count.times do |i|

    watch_name = name_format % i
    God.watch do |w|
      w.name = watch_name
      w.group = group
      w.interval = 15.seconds

      w.dir = rails_root
      w.env = env_vars
      w.start = "#{rake} jobs:work RAILS_ENV=production"
      w.log = "#{rails_root}/log/delayed_job/#{watch_name}.log"

      # restart if memory gets too high
      w.transition(:up, :restart) do |on|
        on.condition(:memory_usage) do |c|
          c.above = 300.megabytes
          c.times = 2
        end
      end

      # determine the state on startup
      w.transition(:init, { true => :up, false => :start }) do |on|
        on.condition(:process_running) do |c|
          c.running = true
        end
      end
      
      # determine when process has finished starting
      w.transition([:start, :restart], :up) do |on|
        on.condition(:process_running) do |c|
          c.running = true
          c.interval = 5.seconds
        end
        
        # failsafe
        on.condition(:tries) do |c|
          c.times = 5
          c.transition = :start
          c.interval = 5.seconds
        end
      end
      
      # start if process is not running
      w.transition(:up, :start) do |on|
        on.condition(:process_running) do |c|
          c.running = false
        end
      end
    end
    
  end
end
rails_root = "/Users/mint/Sites/mediamedoi/current"
ruby = "/usr/local/rvm/wrappers/ruby-1.9.2-tv1_9_2_0/ruby"
rake = "/usr/local/rvm/wrappers/ruby-1.9.2-tv1_9_2_0/rake"
run_as = "mint"

worker_groups = {
  "workers" => {
    "count" => 3,
    "name" => "mediamedoi-dj-worker-%s",
    "group" => "mediamedoi-dj-workers",
    "MIN_PRIORITY" => 0,
    "MAX_PRIORITY" => 99,
    "SLEEP_DELAY" => 1
  },
  "encoders" => {
    "count" => 1,
    "name" => "mediamedoi-dj-encoder-%s",
    "group" => "mediamedoi-dj-encoders",
    "MIN_PRIORITY" => 100,
    "MAX_PRIORITY" => 1000,
    "SLEEP_DELAY" => 5
  },

  #Assumptions for remote workers:
  #Mapped network drives as:
  #  q: read,  support files (handbrakecli bin)
  #  r: write, output folder
  #  s: read,  input folder, should be the same as media_library_root in app config
  "desktop encoders" => {
    "count" => 1,
    "name" => "mediamedoi-dj-encoder-%s",
    "group" => "mediamedoi-dj-encoders",
    "MIN_PRIORITY" => 100,
    "MAX_PRIORITY" => 1000,
    "SLEEP_DELAY" => 5,
    "REMOTE_ADDRESS" => "Barry@192.168.0.47"
  }
}



def run_on_remote_host(watch,ip_address)

end


worker_groups.each_pair do |label,options|
  name_format = options.delete("name")
  group = options.delete("group")
  count = options.delete("count")

  count.times do |i|

    worker_id = options["REMOTE_ADDRESS"] || "#{run_as}-#{i}@localhost"
    watch_name = name_format % worker_id

    rake_args = options
    rake_args.merge!("ENCODER_WORKER_ID" => worker_id) if group == "mediamedoi-dj-encoders"
    rake_args.merge!("RAILS_ENV" => "production")
    rake_args = rake_args.map { |k,v| "#{k}=#{v}" }.join(" ")

    God.watch do |w|
      w.name = watch_name
      w.group = group
      w.interval = 15.seconds

      w.uid = run_as

      w.dir = rails_root
      w.start = "#{rake} jobs:work #{rake_args}"
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

    #if this is a remote worker, start up a process to start/stop it when the host comes online/offline
    if options["REMOTE_ADDRESS"]
      God.watch do |w|
        monitor_watch_name = watch_name.gsub(/encoder/,'monitor')
        monitor_group_name = group.gsub(/encoders/,'monitors')

        w.name = monitor_watch_name
        w.group = monitor_group_name
        w.interval = 15.seconds

        w.uid = "mint"

        w.dir = rails_root
        w.start = "#{ruby} script/monitor_worker_host #{options["REMOTE_ADDRESS"]} #{watch_name}"
        w.log = "#{rails_root}/log/delayed_job/#{monitor_watch_name}.log"
     
        # start if process is not running
        w.transition(:up, :start) do |on|
          on.condition(:process_running) do |c|
            c.running = false
          end
        end
      end
    end
    
  end
end


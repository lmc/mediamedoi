rails_root = "/Users/mint/Sites/mediamedoi/current"
rake = "/usr/local/rvm/wrappers/ruby-1.9.2-tv1_9_2_0/rake"

worker_groups = {
  "high priority" => {
    "name" => "mediamedoi-dj-high-%d",
    "group" => "mediamedoi-dj-high",
    "count" => 3,
    "MIN_PRIORITY" => 0,
    "MAX_PRIORITY" => 99,
    "SLEEP_DELAY" => 1
  },
  "lower priority" => {
    "name" => "mediamedoi-dj-normal-%d",
    "group" => "mediamedoi-dj-normal",
    "count" => 1,
    "MIN_PRIORITY" => 100,
    "MAX_PRIORITY" => 1000,
    "SLEEP_DELAY" => 5
  },

  #Assumptions for remote workers:
  #Mapped network drives as:
  #  x: read,  support files (handbrakecli bin)
  #  y: write, output folder
  #  z: read,  input folder, should be the same as media_library_root in app config
  "lower priority remote" => {
    "name" => "mediamedoi-dj-normal-remote-%d",
    "group" => "mediamedoi-dj-normal",
    "count" => 1,
    "MIN_PRIORITY" => 100,
    "MAX_PRIORITY" => 1000,
    "SLEEP_DELAY" => 5,
    "REMOTE_ADDRESS" => "handbrake@192.168.0.35" #FIXME: Real ip!
  }
}

worker_groups.each_pair do |label,options|
  name_format = options.delete("name")
  group = options.delete("group")
  count = options.delete("count")
  rake_args = options.merge("RAILS_ENV" => "production").map { |k,v| "#{k}=#{v}" }.join(" ")

  count.times do |i|

    watch_name = name_format % i
    God.watch do |w|
      w.name = watch_name
      w.group = group
      w.interval = 15.seconds

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

      # if it's a remote job, only run the local worker when the host is reachable
      run_on_remote_host(w,options["REMOTE_ADDRESS"]) if options["REMOTE_ADDRESS"]
    end
    
  end
end

def run_on_remote_host(watch,ip_address)
  require 'timeout'

  watch.start_if do |start|
    start.condition(:lambda) do |condition|
      condition.interval = 1.minute
      condition.lambda = lambda do
        begin
          Timeout.timeout(3) {
            `ssh #{ip_address} echo "im_really_running"` =~ /im_really_running/
          }
        rescue Timeout::Error
          false
        end
      end
    end
  end

  watch.stop_if do |stop|
    start.condition(:lambda) do |condition|
      condition.interval = 15.seconds
      condition.lambda = lambda do
        begin
          Timeout.timeout(3) {
            `ssh #{ip_address} echo "im_really_running"` !~ /im_really_running/ #if command doesn't run properly, shut down
          }
        rescue Timeout::Error
          true #timeout, shut down
        end
      end
    end
  end

end

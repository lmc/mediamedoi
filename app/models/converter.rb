require 'open3'
class Converter
  BIN_PATH = '/Applications/HandBrakeCLI'
  OUTPUT_PATH = '/Users/luke/Documents/Converted Videos/'
  DEFAULT_OPTIONS = {
    :preset => "\"iPhone & iPod Touch\""
  }
  
  def self.convert(conversion_queue_item)
    input = conversion_queue_item.media_library_file.filesystem_path
    output = File.join(OUTPUT_PATH,conversion_queue_item.media_library_file.name)
    options = make_options({:input => esc(input),:output => esc(output)}.merge(DEFAULT_OPTIONS))
    cmd = "#{BIN_PATH} #{options}"
    puts cmd
    puts "---"
    puts
    
    progress_line = ""
    buffer = ""
    Open3.popen3(cmd) do |stdin,stdout,stderr|
      while chr = stdout.readchar
        unless chr == "\r"
          buffer << chr
        else
          progress_line = buffer
          buffer = ""

          progress_data = parse_progress_line(progress_line)
          conversion_queue_item.progress = progress_data[:progress]
          conversion_queue_item.time_remaining_seconds = progress_data[:time_remaining]

          conversion_queue_item.publish_updates
        end
      end
    end

    conversion_queue_item.finalised
  end
  
  def self.parse_progress_line(line)
    data = {}
    
    results = line.match(/\AEncoding: task \d+ of \d+, ([0-9\.]+)/)
    data[:progress] = results[1] if results
    
    results = line.match(/avg ([0-9\.]+) fps, ETA (\d+)h(\d+)m(\d+)s\)\Z/)
    if results
      data[:fps] = results[1]

      hours, minutes, seconds = *results[2..-1]
      data[:time_remaining] = [hours, minutes, seconds]
    end
    
    puts data.inspect
    data
  end
  
  def self.make_options(options_hash)
    options_hash.map { |option,value| "--#{option} #{value}"}.join(" ")
  end
  
  #TODO: Sanitize this
  def self.esc(string)
    "\"#{string}\""
  end
end
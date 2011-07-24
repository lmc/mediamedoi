require 'open3'
class Converter
  BIN_PATH = Mediamedoi::Application.app_config[:handbrake_path]
  OUTPUT_PATH = Mediamedoi::Application.app_config[:output_path]
  SUBTITLE_INDEX = 1
  DEFAULT_OPTIONS = {
    :preset => '"iPhone 4"',
    :subtitle_forced => SUBTITLE_INDEX,
    :subtitle => SUBTITLE_INDEX,
    :subtitle_burn => SUBTITLE_INDEX,
    :subtitle_default => SUBTITLE_INDEX,
    :format => 'mp4'
  }

  def self.scan(conversion_queue_item)
    input = conversion_queue_item.media_library_file.filesystem_path
    options = make_options({:input => esc(input),:scan => true})

    cmd = "#{BIN_PATH} #{options}"

    titles = cmd.scan(/\+ title (\d+):([\s\S]+)/m)
    titles.each do |title|
      index = title[0].to_i
      data = title[1]

      duration = data.scan(/\+ duration: (\d+):(\d+):(\d+)/)[0].map(&:to_i)
      duration_i  = duration[2]
      duration_i += duration[1].minutes
      duration_i += duration[0].hours

      video_data = data.scan(/\+ size: (\d+)x(\d+), pixel aspect: (\d+)\/(\d+), display aspect: ([0-9\.]+), ([0-9\.]+) fps/)[0]
      video_width = video_data[0].to_i
      video_height = video_data[1].to_i
      video_pixel_ratio = Rational(video_data[2],video_data[3])
      video_display_ratio = video_data[4].to_f
      video_fps = video_data[5].to_f

      #TODO: Handle chapter/audio/subtitle scanning
=begin
  + chapters:
    + 1: cells 0->0, 0 blocks, duration 00:04:50
    + 2: cells 0->0, 0 blocks, duration 00:01:29
    + 3: cells 0->0, 0 blocks, duration 00:02:06
    + 4: cells 0->0, 0 blocks, duration 00:04:54
    + 5: cells 0->0, 0 blocks, duration 00:09:23
    + 6: cells 0->0, 0 blocks, duration 00:00:34
    + 7: cells 0->0, 0 blocks, duration 00:00:14
    + 8: cells 0->0, 0 blocks, duration 00:00:04
  + audio tracks:
    + 1, Japanese (VORBIS) (2.0 ch) (iso639-2: jpn)
  + subtitle tracks:
    + 1, English (iso639-2: eng) (Text)(SSA)
=end
    end
  end
  
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
      while !stdout.eof? && chr = stdout.readchar
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

    conversion_queue_item.finalised!
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
    options_hash.map do |option,value|
      option = option.to_s.dasherize
      value = value === true ? "" : " #{value}"
      "--#{option}#{value}"
    end.join(" ")
  end
  
  #TODO: Sanitize this
  def self.esc(string)
    "\"#{string}\""
  end
end
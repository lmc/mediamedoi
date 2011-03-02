require 'open3'
class Converter
  BIN_PATH = '/Applications/HandBrakeCLI'
  OUTPUT_PATH = '/Users/luke/Documents/Converted Videos/'
  DEFAULT_OPTIONS = {
    :preset => "\"iPhone & iPod Touch\""
  }
  
  def self.convert(media_library_file)
    input = media_library_file.filesystem_path
    output = File.join(OUTPUT_PATH,media_library_file.name)
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
          progress_line, buffer = buffer, ""
          puts progress_line
        end
      end
    end
  end
  
  def self.make_options(options_hash)
    options_hash.map { |option,value| "--#{option} #{value}"}.join(" ")
  end
  
  #TODO: Sanitize this
  def self.esc(string)
    "\"#{string}\""
  end
end
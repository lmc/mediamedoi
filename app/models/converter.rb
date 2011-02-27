require 'open3'
class Converter
  BIN_PATH = '/Applications/HandBrakeCLI'
  OUTPUT_PATH = '/Users/luke/Documents/Converted Videos/'
  DEFAULT_OPTIONS = {
    
  }
  
  def self.convert(media_library_file)
    input = media_library_file.filesystem_path
    output = File.join(OUTPUT_PATH,media_library_file.name)
    options = make_options({:input => esc(input),:output => esc(output)}.merge(DEFAULT_OPTIONS))
    cmd = "#{BIN_PATH} #{options}"
    #stdin, stdout, stderr = Open3.popen3(cmd)
    #[stdin,stdout,stderr]
  end
  
  def self.make_options(options_hash)
    options_hash.map { |option,value| "--#{option} #{value}"}.join(" ")
  end
  
  #TODO: Sanitize this
  def self.esc(string)
    "\"#{string}\""
  end
end
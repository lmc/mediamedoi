class MediaLibraryDir
  attr_accessor :path
  
  def initialize(path)
    self.path = path
  end
  
  def entries
    fs_path = self.class.path_on_fs(path)
    self.class.clean_dir_listing(Dir.entries(fs_path)).map do |file_name|
      MediaLibraryFile.new(File.join(path,file_name))
    end.sort_by(&:name)
  end
  
  private
  
  def self.path_on_fs(path)
    File.join(MediaLibrary::ROOT,path)
  end
  
  IGNORE_DIR_ENTRIES = ['.','..']
  def self.clean_dir_listing(entries)
    entries.reject { |entry| IGNORE_DIR_ENTRIES.include?(entries) }
  end
  
end
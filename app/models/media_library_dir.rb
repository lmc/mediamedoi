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
  
  def name
    File.basename(path)
  end
  
  def up_path
    path.split('/')[-2] || '/'
  end
  
  def show_up_path?
    !(up_path == '/')
  end
  
  
  private
  
  def self.path_on_fs(path)
    File.join(MediaLibrary::ROOT,path)
  end
  
  IGNORE_DIR_ENTRIES = ['.','..','.DS_Store','.Spotlight-V100','.Trashes','.fseventsd','ehthumbs_vista.db']
  def self.clean_dir_listing(entries)
    entries.reject { |entry| IGNORE_DIR_ENTRIES.include?(entry) }
  end
  
end
class MediaLibraryFile
  attr_accessor :path
  
  def initialize(path)
    self.path = path
  end
  
  def name
    File.basename(path)
  end
  
  def filesystem_path(root = MediaLibrary::ROOT)
    File.join(root,path)
  end
  
  def directory?
    File.directory?(filesystem_path)
  end
  
  def entries_count
    return nil unless directory?
    Dir.entries(filesystem_path).size
  end
  
  def to_html5_data
    {:name => name,:path => path,:filesystem_path => filesystem_path}
  end
end
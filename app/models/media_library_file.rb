class MediaLibraryFile
  attr_accessor :path
  
  def initialize(path)
    self.path = path
  end
  
  def name
    File.basename(path)
  end
  
  def filesystem_path
    File.join(MediaLibrary::ROOT,path)
  end
  
  def to_html5_data
    {:name => name,:path => path,:filesystem_path => filesystem_path}
  end
end
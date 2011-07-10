class MediaLibrary
  ROOT = Mediamedoi::Application.app_config[:media_library_root]
  
  def self.find_by_path(path)
    MediaLibraryDir.new(path)
  end
  
end

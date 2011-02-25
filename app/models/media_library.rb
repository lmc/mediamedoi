class MediaLibrary
  ROOT = YAML.load_file(Rails.root.join('config','mediamedoi.yml'))[Rails.env]['media_library_root']
  
  def self.find_by_path(path)
    MediaLibraryDir.new(path)
  end
  
end

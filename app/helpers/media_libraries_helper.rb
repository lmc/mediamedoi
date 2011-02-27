module MediaLibrariesHelper
  def classes_for_media_library(media_library)
    classes = []
    classes << 'no_back' unless media_library.show_up_path?
    classes.join(' ')
  end
end

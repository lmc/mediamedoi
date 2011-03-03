class ConversionQueueItem < ActiveRecord::Base
  validates_presence_of :file_path
  
  def media_library_file
    MediaLibraryFile.new(self.file_path)
  end
  
  def convert!
    Converter.convert(self)
  end
  
end

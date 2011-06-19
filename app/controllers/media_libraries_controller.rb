class MediaLibrariesController < ApplicationController
  
  def index
    @path = params[:path] || "/"
    @media_libraries = MediaLibrary.find_by_path(@path)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def convert
    @path = params[:path]
    @media_library_file = MediaLibraryFile.new(@path)
    @conversion_queue_item = ConversionQueueItem.new_from_media_library_file(@media_library_file)
    #ccc = Converter.convert(@media_library_file)
    #debugger
    #'sdf'
  end
  
end

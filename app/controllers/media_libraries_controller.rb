class MediaLibrariesController < ApplicationController
  
  def index
    @media_libraries = MediaLibrary.find_by_path("/")

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
end

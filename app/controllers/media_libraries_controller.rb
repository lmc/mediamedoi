class MediaLibrariesController < ApplicationController
  # GET /media_libraries
  # GET /media_libraries.xml
  def index
    @media_libraries = MediaLibrary.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @media_libraries }
    end
  end

  # GET /media_libraries/1
  # GET /media_libraries/1.xml
  def show
    @media_library = MediaLibrary.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @media_library }
    end
  end

  # GET /media_libraries/new
  # GET /media_libraries/new.xml
  def new
    @media_library = MediaLibrary.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @media_library }
    end
  end

  # GET /media_libraries/1/edit
  def edit
    @media_library = MediaLibrary.find(params[:id])
  end

  # POST /media_libraries
  # POST /media_libraries.xml
  def create
    @media_library = MediaLibrary.new(params[:media_library])

    respond_to do |format|
      if @media_library.save
        format.html { redirect_to(@media_library, :notice => 'Media library was successfully created.') }
        format.xml  { render :xml => @media_library, :status => :created, :location => @media_library }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @media_library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /media_libraries/1
  # PUT /media_libraries/1.xml
  def update
    @media_library = MediaLibrary.find(params[:id])

    respond_to do |format|
      if @media_library.update_attributes(params[:media_library])
        format.html { redirect_to(@media_library, :notice => 'Media library was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @media_library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /media_libraries/1
  # DELETE /media_libraries/1.xml
  def destroy
    @media_library = MediaLibrary.find(params[:id])
    @media_library.destroy

    respond_to do |format|
      format.html { redirect_to(media_libraries_url) }
      format.xml  { head :ok }
    end
  end
end

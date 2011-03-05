class ConversionQueueItem < ActiveRecord::Base
  JUGGERNAUT_CHANNEL = "global"
  validates_presence_of :file_path
  
  def media_library_file
    MediaLibraryFile.new(self.file_path)
  end
  
  def convert!
    Converter.convert(self)
  end
  
  def publish_updates
    Juggernaut.publish(JUGGERNAUT_CHANNEL,{
      :id => self.id, :operation => 'conversion', :progress => self.progress, :time_remaining => self.time_remaining
    })
  end
  
  def time_remaining_seconds=(seconds_or_array)
    if seconds_or_array.is_a?(Array)
      self.time_remaining  = seconds_or_array[2].to_i
      self.time_remaining += seconds_or_array[1].to_i.minutes
      self.time_remaining += seconds_or_array[0].to_i.hours
    else
      self.time_remaining = seconds_or_array
    end
  end
  
end

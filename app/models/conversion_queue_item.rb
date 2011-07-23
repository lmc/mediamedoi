class ConversionQueueItem < ActiveRecord::Base
  JUGGERNAUT_CHANNEL = "global"
  MODEL_UPDATE_INTERVAL = 15.seconds
  validates_presence_of :file_path

  after_create :generate_job!

  def self.new_from_media_library_file(media_library_file)
    self.new(:file_path => media_library_file.path,:position => self.last_position)
  end

  def self.last_position
    self.order('position DESC').limit(1).select('position').first.position rescue 0
  end
  
  def media_library_file
    MediaLibraryFile.new(self.file_path)
  end
  
  def convert!
    Converter.convert(self)
  end

  def finalised!
    #called when the conversion finishes
  end
  
  def publish_updates
    #publish_juggernaut
    publish_model if should_publish_model?
  end

  def publish_juggernaut
    Juggernaut.publish(JUGGERNAUT_CHANNEL,{
      :id => self.id, :operation => 'conversion', :progress => self.progress, :time_remaining => self.time_remaining
    })    
  end

  def publish_model
    self.save
  end

  def should_publish_model?
    puts "#{(Time.zone.now.to_i - self.updated_at.to_i)} >= #{MODEL_UPDATE_INTERVAL}"
    puts "#{((Time.zone.now.to_i - self.updated_at.to_i) >= MODEL_UPDATE_INTERVAL).inspect}"
    (Time.zone.now.to_i - self.updated_at.to_i) >= MODEL_UPDATE_INTERVAL
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


  def generate_job!
    self.delayed_job_id = self.delay(self.job_options).convert!
    self.save!
  end

  def job_priority
    self.position
  end

  def job_options
    { :run_at => Time.zone.now, :priority => self.job_priority }
  end
  
end

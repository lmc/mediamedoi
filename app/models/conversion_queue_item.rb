class ConversionQueueItem < ActiveRecord::Base
  JUGGERNAUT_CHANNEL = "global"
  MODEL_UPDATE_INTERVAL = 3.seconds
  validates_presence_of :file_path

  after_create :generate_job!

  MINIMUM_PRIORITY = 100

  STATUSES = ['queued','processing','failed','completed'].freeze
  DEFAULT_STATUS = STATUSES[0]

  def self.new_from_media_library_file(media_library_file)
    self.new(:file_path => media_library_file.path,:position => self.last_position)
  end

  def self.last_position
    self.order('position DESC').limit(1).select('position').first.position rescue 0
  end
  
  def media_library_file
    MediaLibraryFile.new(self.file_path)
  end

  def scan!
    Converter.scan(self)
  end

  def after_scan
    self.delayed_job_id = self.delay(self.job_options).convert!
    self.save!
  end
  
  def convert!
    self.class.remote_job_before if ENV["REMOTE_ADDRESS"]
    Converter.convert(self)
  end

  def on_start!
    self.started_at = Time.zone.now
    self.status = 'processing'
    self.worker, self.host = *ENV["ENCODER_WORKER_ID"].split('@')
    self.save!
  end

  def on_finish!
    self.finished_at = Time.zone.now
    self.status = 'completed'
    self.save!
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
    self.delayed_job_id = self.delay(self.scan_job_options).scan!
    self.save!
  end

  def job_priority
    self.position + MINIMUM_PRIORITY
  end

  def scan_job_options
    { :run_at => Time.zone.now, :priority => 0 }
  end

  def job_options
    { :run_at => Time.zone.now, :priority => self.job_priority }
  end


  def self.remote_job_before
    puts "remote_job_before"
    puts ENV.inspect
  end

  def self.remote_job_after
    
  end
  
end

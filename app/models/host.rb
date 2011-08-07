class Host
  attr_accessor :user, :host
  GOD_PREFIX = "mediamedoi-dj-encoder-"
  GOD_GROUP = "mediamedoi-dj-encoders"
  UP_SUFFIX = /: up$/

  def self.all_online
    cmd = "sudo god status #{GOD_GROUP}"
    worker_ids = `#{cmd}`.gsub(/^#{GOD_GROUP}:\n/,'').split("\n").map(&:strip)
    up_workers = worker_ids.select { |worker| worker =~ UP_SUFFIX }.map { |worker| worker.gsub(UP_SUFFIX,'') }

    users_hosts = up_workers.map { |worker| worker.gsub(/^#{GOD_PREFIX}/,'').split('@') }
    users_hosts.map { |user,host| new(user,host) }
  end

  def initialize(user,host)
    self.user, self.host = user, host
  end

  def to_json(options={})
    options[:methods] ||= []
    options[:methods] += [:gigapixels_second,:gigapixels_second_human]
    super(options)
  end

  def as_json(options={})
    options[:methods] ||= []
    options[:methods] += [:gigapixels_second,:gigapixels_second_human]
    super(options)
  end

  def gigapixels_second
    #TODO: Indexes for this
    #FIXME: Cache this or something!
    gpx_secs = ConversionQueueItem.gigapixels_for_host(self.host).limit(5).map(&:encoded_at_gigapixels_second)
    gpx_secs.inject{ |sum, gpx_sec| sum + gpx_sec }.to_f / gpx_secs.size #average
  end

  def gigapixels_second_human
    ActionView::Helpers::NumberHelper.number_to_human_size(self.gigapixels_second).gsub(/B$/,'')
  end

end
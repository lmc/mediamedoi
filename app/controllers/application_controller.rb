class ApplicationController < ActionController::Base
  extend ActiveSupport::Memoizable
  
  protect_from_forgery

  def root_path
  	Mediamedoi::Application.app_config[:mount_url].to_s
  end
  memoize :root_path
  helper_method :root_path

end

class HostsController < ApplicationController
  respond_to :html, :json

  def index
    @hosts = Host.all_online
    respond_with(@hosts)
  end

end

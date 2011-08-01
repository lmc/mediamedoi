class ConversionQueueItemsController < ApplicationController
  respond_to :html, :json

  def index
    @conversion_queue_items = ConversionQueueItem.order('position ASC').all
    respond_with(@conversion_queue_items)
  end

end

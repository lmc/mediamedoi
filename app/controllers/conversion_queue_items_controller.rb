class ConversionQueueItemsController < ApplicationController
  def index
  	@conversion_queue_items = ConversionQueueItem.order('position ASC').all
  end

end

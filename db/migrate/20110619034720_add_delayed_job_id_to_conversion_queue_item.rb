class AddDelayedJobIdToConversionQueueItem < ActiveRecord::Migration
  def self.up
    add_column :conversion_queue_items, :delayed_job_id, :integer
  end

  def self.down
    remove_column :conversion_queue_items, :delayed_job_id
  end
end

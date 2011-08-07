class AddWorkerAndHostToConversionQueueItems < ActiveRecord::Migration
  def self.up
    add_column :conversion_queue_items, :worker, :string
    add_column :conversion_queue_items, :host, :string
  end

  def self.down
    remove_column :conversion_queue_items, :host
    remove_column :conversion_queue_items, :worker
  end
end

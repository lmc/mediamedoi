class AddMediaLengthToConversionQueueItem < ActiveRecord::Migration
  def self.up
    add_column :conversion_queue_items, :media_length_seconds, :integer
    add_column :conversion_queue_items, :media_length_frames, :integer
    add_column :conversion_queue_items, :media_fps, :float
    add_column :conversion_queue_items, :media_width, :integer
    add_column :conversion_queue_items, :media_height, :integer
  end

  def self.down
    remove_column :conversion_queue_items, :media_height
    remove_column :conversion_queue_items, :media_width
    remove_column :conversion_queue_items, :media_fps
    remove_column :conversion_queue_items, :media_length_frames
    remove_column :conversion_queue_items, :media_length_seconds
  end
end

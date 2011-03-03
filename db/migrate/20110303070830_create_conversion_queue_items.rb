class CreateConversionQueueItems < ActiveRecord::Migration
  def self.up
    create_table :conversion_queue_items do |t|
      t.integer :position
      t.string :file_path
      t.string :progress
      t.integer :time_remaining
      t.datetime :started_at
      t.datetime :finished_at
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :conversion_queue_items
  end
end

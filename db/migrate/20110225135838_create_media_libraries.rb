class CreateMediaLibraries < ActiveRecord::Migration
  def self.up
    create_table :media_libraries do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :media_libraries
  end
end

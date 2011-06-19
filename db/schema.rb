# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110619035835) do

  create_table "conversion_queue_items", :force => true do |t|
    t.integer  "position"
    t.string   "file_path"
    t.string   "progress"
    t.integer  "time_remaining"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "media_length_seconds"
    t.integer  "media_length_frames"
    t.float    "media_fps"
    t.integer  "media_width"
    t.integer  "media_height"
    t.integer  "delayed_job_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

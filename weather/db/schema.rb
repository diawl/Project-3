# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150514042209) do

  create_table "conditions", force: :cascade do |t|
    t.integer  "measurement_id"
    t.string   "icon"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "conditions", ["measurement_id"], name: "index_conditions_on_measurement_id"

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",            null: false
    t.text     "log"
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "crono_jobs", ["job_id"], name: "index_crono_jobs_on_job_id", unique: true

  create_table "locations", force: :cascade do |t|
    t.integer  "postcode_id"
    t.string   "loc_id"
    t.float    "lat"
    t.float    "lon"
    t.boolean  "active"
    t.string   "loc_type"
    t.string   "state"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "locations", ["postcode_id"], name: "index_locations_on_postcode_id"

  create_table "measurements", force: :cascade do |t|
    t.integer  "wdate_id"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "measurements", ["wdate_id"], name: "index_measurements_on_wdate_id"

  create_table "postcodes", force: :cascade do |t|
    t.integer  "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rainfalls", force: :cascade do |t|
    t.integer  "measurement_id"
    t.float    "precip"
    t.float    "probability"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "rainfalls", ["measurement_id"], name: "index_rainfalls_on_measurement_id"

  create_table "temperatures", force: :cascade do |t|
    t.integer  "measurement_id"
    t.float    "temp"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "temperatures", ["measurement_id"], name: "index_temperatures_on_measurement_id"

  create_table "wdates", force: :cascade do |t|
    t.integer  "location_id"
    t.string   "date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "wdates", ["location_id"], name: "index_wdates_on_location_id"

  create_table "wind_directions", force: :cascade do |t|
    t.integer  "measurement_id"
    t.integer  "bearing"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "wind_directions", ["measurement_id"], name: "index_wind_directions_on_measurement_id"

  create_table "wind_speeds", force: :cascade do |t|
    t.integer  "measurement_id"
    t.float    "speed"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "wind_speeds", ["measurement_id"], name: "index_wind_speeds_on_measurement_id"

end

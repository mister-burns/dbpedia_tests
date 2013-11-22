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

ActiveRecord::Schema.define(version: 20131122065748) do

  create_table "infoboxes", force: true do |t|
    t.string   "label"
    t.text     "infobox"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
  end

  create_table "labels", force: true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "livejsons", force: true do |t|
    t.string   "label"
    t.text     "jsondata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liveshows", force: true do |t|
    t.string   "label"
    t.integer  "number_of_episodes_owl"
    t.integer  "number_of_seasons_owl"
    t.integer  "number_of_episodes_prop"
    t.integer  "number_of_seasons_prop"
    t.string   "language"
    t.string   "country"
    t.datetime "release_date"
    t.datetime "first_aired"
    t.text     "info_box"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shows", force: true do |t|
    t.integer  "wikipage_id"
    t.string   "show_name"
    t.integer  "number_of_episodes"
    t.integer  "number_of_seasons"
    t.datetime "first_aired"
    t.datetime "last_aired"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "genre_1"
    t.string   "genre_2"
    t.string   "genre_3"
    t.string   "genre_4"
    t.string   "genre_5"
    t.string   "format_1"
    t.string   "format_2"
    t.string   "format_3"
    t.string   "format_4"
    t.string   "format_5"
  end

  create_table "wikicategoryapis", force: true do |t|
    t.integer  "page_id"
    t.string   "page_title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

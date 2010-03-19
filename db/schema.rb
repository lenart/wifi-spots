# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100319065405) do

  create_table "categories", :force => true do |t|
    t.string   "name",        :limit => 50
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string "name"
    t.float  "lat"
    t.float  "lng"
    t.string "cached_slug"
  end

  add_index "cities", ["cached_slug"], :name => "index_cities_on_cached_slug"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "spots", :force => true do |t|
    t.string   "title",       :limit => 100
    t.integer  "category_id"
    t.text     "location"
    t.string   "city",        :limit => 50
    t.text     "notes"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat"
    t.float    "lng"
    t.integer  "zoom"
    t.string   "permalink"
    t.boolean  "deleted",                    :default => false
    t.string   "url"
    t.boolean  "open"
    t.string   "ssid",        :limit => 50
    t.string   "key",         :limit => 50
    t.string   "author"
    t.string   "cached_slug"
  end

  add_index "spots", ["cached_slug"], :name => "index_spots_on_cached_slug"
  add_index "spots", ["category_id"], :name => "index_spots_on_category_id"
  add_index "spots", ["lat", "lng"], :name => "index_spots_on_lat_and_lng"

  create_table "users", :force => true do |t|
    t.string   "email",             :limit => 100,                 :null => false
    t.string   "crypted_password",                                 :null => false
    t.string   "password_salt",     :limit => 40,                  :null => false
    t.string   "name",              :limit => 50,  :default => "", :null => false
    t.string   "persistence_token",                                :null => false
    t.string   "perishable_token",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "changes"
    t.integer  "number"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end

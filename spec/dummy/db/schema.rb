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

ActiveRecord::Schema.define(version: 20120823163756) do

  create_table "redirect_rules", force: :cascade do |t|
    t.string   "source",                   limit: 255,                 null: false
    t.boolean  "source_is_regex",          limit: 1,   default: false, null: false
    t.boolean  "source_is_case_sensitive", limit: 1,   default: false, null: false
    t.string   "destination",              limit: 255,                 null: false
    t.boolean  "active",                   limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redirect_rules", ["active"], name: "index_redirect_rules_on_active", using: :btree
  add_index "redirect_rules", ["source"], name: "index_redirect_rules_on_source", using: :btree
  add_index "redirect_rules", ["source_is_case_sensitive"], name: "index_redirect_rules_on_source_is_case_sensitive", using: :btree
  add_index "redirect_rules", ["source_is_regex"], name: "index_redirect_rules_on_source_is_regex", using: :btree

  create_table "request_environment_rules", force: :cascade do |t|
    t.integer  "redirect_rule_id",                    limit: 4,                   null: false
    t.string   "environment_key_name",                limit: 255,                 null: false
    t.string   "environment_value",                   limit: 255,                 null: false
    t.boolean  "environment_value_is_regex",          limit: 1,   default: false, null: false
    t.boolean  "environment_value_is_case_sensitive", limit: 1,   default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "request_environment_rules", ["redirect_rule_id"], name: "index_request_environment_rules_on_redirect_rule_id", using: :btree

end

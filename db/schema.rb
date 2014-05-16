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

ActiveRecord::Schema.define(version: 20140515163524) do

  create_table "imprintables", force: true do |t|
    t.string   "name"
    t.string   "catalog_number"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "orders", force: true do |t|
    t.string   "email"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "company"
    t.string   "twitter"
    t.string   "name"
    t.string   "po"
    t.datetime "in_hand_by"
    t.string   "terms"
    t.boolean  "tax_exempt"
    t.string   "tax_id_number"
    t.boolean  "is_redo"
    t.text     "redo_reason"
    t.string   "sales_status",                               default: "pending"
    t.string   "delivery_method"
    t.decimal  "total",             precision: 10, scale: 2
    t.datetime "deleted_at"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission_amount", precision: 10, scale: 2
  end

  create_table "shipping_methods", force: true do |t|
    t.string   "name"
    t.string   "tracking_url"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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

ActiveRecord::Schema.define(version: 20140523170638) do

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "sku"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colors", force: true do |t|
    t.string   "name"
    t.string   "sku"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imprintable_variants", force: true do |t|
    t.integer  "imprintable_id"
    t.string   "weight"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imprintables", force: true do |t|
    t.string   "name"
    t.string   "catalog_number"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "order_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "sales_status"
    t.string   "delivery_method"
    t.decimal  "total",             precision: 10, scale: 2
    t.datetime "deleted_at"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission_amount", precision: 10, scale: 2
    t.integer  "user_id"
  end

  create_table "shipping_methods", force: true do |t|
    t.string   "name"
    t.string   "tracking_url"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sizes", force: true do |t|
    t.string   "name"
    t.string   "display_value"
    t.string   "sku"
    t.integer  "sort_order"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence"
  end

  create_table "styles", force: true do |t|
    t.string   "name"
    t.string   "catalog_no"
    t.text     "description"
    t.string   "sku"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "deleted_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end

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

ActiveRecord::Schema.define(version: 20140617173446) do

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "sku"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "brands", ["deleted_at"], name: "index_brands_on_deleted_at", using: :btree

  create_table "colors", force: true do |t|
    t.string   "name"
    t.string   "sku"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "imprintable_variant_id"
    t.datetime "deleted_at"
  end

  add_index "colors", ["deleted_at"], name: "index_colors_on_deleted_at", using: :btree
  add_index "colors", ["imprintable_variant_id"], name: "color_imprintable_variant_id_ix", using: :btree

  create_table "coordinates_imprintables", id: false, force: true do |t|
    t.integer "coordinate_id"
    t.integer "imprintable_id"
  end

  add_index "coordinates_imprintables", ["coordinate_id", "imprintable_id"], name: "coordinate_imprintable_index", using: :btree

  create_table "imprint_methods", force: true do |t|
    t.string   "name"
    t.string   "production_name"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "imprint_methods", ["deleted_at"], name: "index_imprint_methods_on_deleted_at", using: :btree

  create_table "imprint_methods_imprintables", id: false, force: true do |t|
    t.integer "imprint_method_id"
    t.integer "imprintable_id"
  end

  add_index "imprint_methods_imprintables", ["imprintable_id", "imprint_method_id"], name: "imprint_method_imprintables_index", using: :btree

  create_table "imprintable_linker_table", id: false, force: true do |t|
    t.integer "imprintable_id"
    t.integer "coordinate_id"
    t.integer "store_id"
  end

  create_table "imprintable_variants", force: true do |t|
    t.integer  "imprintable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size_id"
    t.integer  "color_id"
    t.datetime "deleted_at"
  end

  add_index "imprintable_variants", ["deleted_at"], name: "index_imprintable_variants_on_deleted_at", using: :btree

  create_table "imprintables", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flashable"
    t.text     "special_considerations"
    t.boolean  "polyester"
    t.integer  "style_id"
    t.string   "sizing_category"
    t.datetime "deleted_at"
    t.text     "proofing_template_name"
    t.string   "material"
    t.boolean  "standard_offering"
  end

  add_index "imprintables", ["deleted_at"], name: "index_imprintables_on_deleted_at", using: :btree
  add_index "imprintables", ["style_id"], name: "style_id_ix", using: :btree

  create_table "imprintables_stores", id: false, force: true do |t|
    t.integer "imprintable_id"
    t.integer "store_id"
  end

  add_index "imprintables_stores", ["imprintable_id", "store_id"], name: "index_imprintables_stores_on_imprintable_id_and_store_id", using: :btree

  create_table "ink_colors", force: true do |t|
    t.string   "name"
    t.integer  "imprint_method_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ink_colors", ["deleted_at"], name: "index_ink_colors_on_deleted_at", using: :btree
  add_index "ink_colors", ["imprint_method_id"], name: "index_ink_colors_on_imprint_method_id", using: :btree

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "order_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree

  create_table "line_items", force: true do |t|
    t.string   "name"
    t.integer  "quantity"
    t.boolean  "taxable"
    t.text     "description"
    t.integer  "job_id"
    t.integer  "imprintable_variant_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",             precision: 10, scale: 2
  end

  add_index "line_items", ["job_id"], name: "index_line_items_on_job_id", using: :btree

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
    t.integer  "store_id"
    t.integer  "salesperson_id"
  end

  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree

  create_table "print_locations", force: true do |t|
    t.string   "name"
    t.integer  "imprint_method_id"
    t.decimal  "max_height",        precision: 8, scale: 2
    t.decimal  "max_width",         precision: 8, scale: 2
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "print_locations", ["deleted_at"], name: "index_print_locations_on_deleted_at", using: :btree
  add_index "print_locations", ["imprint_method_id"], name: "index_print_locations_on_imprint_method_id", using: :btree

  create_table "shipping_methods", force: true do |t|
    t.string   "name"
    t.string   "tracking_url"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_methods", ["deleted_at"], name: "index_shipping_methods_on_deleted_at", using: :btree

  create_table "sizes", force: true do |t|
    t.string   "name"
    t.string   "display_value"
    t.string   "sku"
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "imprintable_variant_id"
    t.datetime "deleted_at"
  end

  add_index "sizes", ["deleted_at"], name: "index_sizes_on_deleted_at", using: :btree
  add_index "sizes", ["imprintable_variant_id"], name: "size_imprintable_variant_id_ix", using: :btree

  create_table "stores", force: true do |t|
    t.string   "name"
    t.string   "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stores", ["deleted_at"], name: "index_stores_on_deleted_at", using: :btree

  create_table "styles", force: true do |t|
    t.string   "name"
    t.string   "catalog_no"
    t.text     "description"
    t.string   "sku"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
    t.datetime "deleted_at"
  end

  add_index "styles", ["brand_id"], name: "brand_id_ix", using: :btree
  add_index "styles", ["deleted_at"], name: "index_styles_on_deleted_at", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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
    t.integer  "store_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end

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

ActiveRecord::Schema.define(version: 20141010010514) do

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "artwork_proofs", force: true do |t|
    t.integer  "artwork_id"
    t.integer  "proof_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_request_artworks", force: true do |t|
    t.integer  "artwork_request_id"
    t.integer  "artwork_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_request_ink_colors", force: true do |t|
    t.integer  "artwork_request_id"
    t.integer  "ink_color_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_request_jobs", force: true do |t|
    t.integer  "artwork_request_id"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_requests", force: true do |t|
    t.text     "description"
    t.integer  "artist_id"
    t.integer  "imprint_method_id"
    t.integer  "print_location_id"
    t.integer  "salesperson_id"
    t.datetime "deadline"
    t.string   "artwork_status"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "priority"
  end

  create_table "artworks", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "artist_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets", force: true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "description"
    t.integer  "assetable_id"
    t.string   "assetable_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "sku"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "retail",     default: false
  end

  add_index "brands", ["deleted_at"], name: "index_brands_on_deleted_at", using: :btree
  add_index "brands", ["retail"], name: "index_brands_on_retail", using: :btree

  create_table "colors", force: true do |t|
    t.string   "name"
    t.string   "sku"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "retail",     default: false
    t.string   "hexcode"
  end

  add_index "colors", ["deleted_at"], name: "index_colors_on_deleted_at", using: :btree
  add_index "colors", ["retail"], name: "index_colors_on_retail", using: :btree

  create_table "coordinate_imprintables", force: true do |t|
    t.integer  "coordinate_id"
    t.integer  "imprintable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coordinate_imprintables", ["coordinate_id", "imprintable_id"], name: "coordinate_imprintable_index", using: :btree

  create_table "imprint_method_imprintables", force: true do |t|
    t.integer  "imprint_method_id"
    t.integer  "imprintable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "imprint_method_imprintables", ["imprintable_id", "imprint_method_id"], name: "imprint_method_imprintables_index", using: :btree

  create_table "imprint_methods", force: true do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deletable",  default: true
  end

  add_index "imprint_methods", ["deleted_at"], name: "index_imprint_methods_on_deleted_at", using: :btree

  create_table "imprintable_categories", force: true do |t|
    t.string   "name"
    t.integer  "imprintable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imprintable_stores", force: true do |t|
    t.integer  "imprintable_id"
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "imprintable_stores", ["imprintable_id", "store_id"], name: "index_imprintable_stores_on_imprintable_id_and_store_id", using: :btree

  create_table "imprintable_variants", force: true do |t|
    t.integer  "imprintable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size_id"
    t.integer  "color_id"
    t.datetime "deleted_at"
    t.decimal  "weight",         precision: 10, scale: 0
  end

  add_index "imprintable_variants", ["deleted_at"], name: "index_imprintable_variants_on_deleted_at", using: :btree

  create_table "imprintables", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flashable"
    t.text     "special_considerations"
    t.boolean  "polyester"
    t.string   "sizing_category"
    t.datetime "deleted_at"
    t.text     "proofing_template_name"
    t.string   "material"
    t.boolean  "standard_offering"
    t.string   "main_supplier"
    t.string   "supplier_link"
    t.string   "weight"
    t.decimal  "base_price",             precision: 10, scale: 2
    t.decimal  "xxl_price",              precision: 10, scale: 2
    t.decimal  "xxxl_price",             precision: 10, scale: 2
    t.decimal  "xxxxl_price",            precision: 10, scale: 2
    t.decimal  "xxxxxl_price",           precision: 10, scale: 2
    t.decimal  "xxxxxxl_price",          precision: 10, scale: 2
    t.string   "style_name"
    t.string   "style_catalog_no"
    t.text     "style_description"
    t.string   "sku"
    t.boolean  "retail",                                          default: false
    t.integer  "brand_id"
    t.decimal  "max_imprint_width",      precision: 8,  scale: 2
    t.decimal  "max_imprint_height",     precision: 8,  scale: 2
    t.string   "common_name"
  end

  add_index "imprintables", ["deleted_at"], name: "index_imprintables_on_deleted_at", using: :btree
  add_index "imprintables", ["main_supplier"], name: "index_imprintables_on_main_supplier", using: :btree

  create_table "imprints", force: true do |t|
    t.integer  "print_location_id"
    t.integer  "job_id"
    t.decimal  "ideal_width",       precision: 10, scale: 0
    t.decimal  "ideal_height",      precision: 10, scale: 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_name_number"
    t.integer  "name_number_id"
  end

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
    t.boolean  "collapsed"
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree

  create_table "line_item_groups", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "quote_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_item_groups", ["quote_id"], name: "index_line_item_groups_on_quote_id", using: :btree

  create_table "line_items", force: true do |t|
    t.string   "name"
    t.integer  "quantity"
    t.boolean  "taxable"
    t.text     "description"
    t.integer  "imprintable_variant_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",             precision: 10, scale: 2
    t.integer  "line_itemable_id"
    t.string   "line_itemable_type"
  end

  add_index "line_items", ["line_itemable_id", "line_itemable_type"], name: "index_line_items_on_line_itemable_id_and_line_itemable_type", using: :btree

  create_table "name_numbers", force: true do |t|
    t.string  "name"
    t.integer "number"
    t.string  "description"
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
    t.string   "delivery_method"
    t.datetime "deleted_at"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission_amount", precision: 10, scale: 2
    t.integer  "store_id"
    t.integer  "salesperson_id"
  end

  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "order_id"
    t.integer  "salesperson_id"
    t.integer  "store_id"
    t.boolean  "refunded"
    t.decimal  "amount",            precision: 10, scale: 2
    t.text     "refund_reason"
    t.datetime "deleted_at"
    t.string   "cc_invoice_no"
    t.string   "cc_batch_no"
    t.string   "check_dl_no"
    t.string   "check_phone_no"
    t.string   "pp_transaction_id"
    t.integer  "payment_method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "proofs", force: true do |t|
    t.string   "status"
    t.integer  "order_id"
    t.datetime "approve_by"
    t.datetime "approved_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_requests", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "approx_quantity"
    t.datetime "date_needed"
    t.text     "description"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "salesperson_id"
  end

  create_table "quotes", force: true do |t|
    t.string   "email"
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "twitter"
    t.string   "name"
    t.datetime "valid_until_date"
    t.datetime "estimated_delivery_date"
    t.integer  "salesperson_id"
    t.integer  "store_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "shipping",                precision: 10, scale: 2
    t.string   "quote_source"
    t.datetime "initialized_at"
  end

  create_table "sample_locations", force: true do |t|
    t.integer "imprintable_id"
    t.integer "store_id"
  end

  create_table "search_boolean_filters", force: true do |t|
    t.string  "field"
    t.boolean "negate"
    t.boolean "value"
  end

  create_table "search_date_filters", force: true do |t|
    t.string   "field"
    t.boolean  "negate"
    t.datetime "value"
    t.string   "comparator", limit: 1
  end

  create_table "search_filter_groups", force: true do |t|
    t.boolean "all"
  end

  create_table "search_filters", force: true do |t|
    t.integer "filter_holder_id"
    t.string  "filter_holder_type"
    t.integer "filter_type_id"
    t.string  "filter_type_type"
  end

  create_table "search_nil_filters", force: true do |t|
    t.string  "field"
    t.boolean "negate"
  end

  create_table "search_number_filters", force: true do |t|
    t.string  "field"
    t.boolean "negate"
    t.decimal "value",                precision: 10, scale: 2
    t.string  "comparator", limit: 1
  end

  create_table "search_phrase_filters", force: true do |t|
    t.string  "field"
    t.boolean "negate"
    t.string  "value"
  end

  create_table "search_queries", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_query_fields", force: true do |t|
    t.integer "query_model_id"
    t.string  "name"
    t.decimal "boost",          precision: 10, scale: 2
    t.integer "phrase"
  end

  create_table "search_query_models", force: true do |t|
    t.integer "query_id"
    t.string  "name"
    t.string  "default_fulltext"
  end

  create_table "search_reference_filters", force: true do |t|
    t.string  "field"
    t.boolean "negate"
    t.integer "value_id"
    t.string  "value_type"
  end

  create_table "search_string_filters", force: true do |t|
    t.string  "field"
    t.boolean "negate"
    t.string  "value"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.string   "name"
    t.string   "val"
    t.string   "encrypted_val"
    t.boolean  "encrypted"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.boolean  "retail",                 default: false
  end

  add_index "sizes", ["deleted_at"], name: "index_sizes_on_deleted_at", using: :btree
  add_index "sizes", ["imprintable_variant_id"], name: "size_imprintable_variant_id_ix", using: :btree
  add_index "sizes", ["retail"], name: "index_sizes_on_retail", using: :btree

  create_table "stores", force: true do |t|
    t.string   "name"
    t.string   "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stores", ["deleted_at"], name: "index_stores_on_deleted_at", using: :btree

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
    t.string   "email",                        default: "", null: false
    t.string   "encrypted_password",           default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",              default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "deleted_at"
    t.integer  "store_id"
    t.string   "authentication_token"
    t.string   "freshdesk_email"
    t.string   "freshdesk_password"
    t.string   "encrypted_freshdesk_password"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end

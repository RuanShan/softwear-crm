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

ActiveRecord::Schema.define(version: 20151023202128) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "artwork_proofs", force: :cascade do |t|
    t.integer  "artwork_id", limit: 4
    t.integer  "proof_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_request_artworks", force: :cascade do |t|
    t.integer  "artwork_request_id", limit: 4
    t.integer  "artwork_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_request_imprints", force: :cascade do |t|
    t.integer "artwork_request_id", limit: 4
    t.integer "imprint_id",         limit: 4
  end

  create_table "artwork_request_ink_colors", force: :cascade do |t|
    t.integer  "artwork_request_id", limit: 4
    t.integer  "ink_color_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_request_jobs", force: :cascade do |t|
    t.integer  "artwork_request_id", limit: 4
    t.integer  "job_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "artwork_requests", force: :cascade do |t|
    t.text     "description",       limit: 65535
    t.integer  "artist_id",         limit: 4
    t.integer  "imprint_method_id", limit: 4
    t.integer  "print_location_id", limit: 4
    t.integer  "salesperson_id",    limit: 4
    t.datetime "deadline"
    t.string   "artwork_status",    limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "priority",          limit: 255
  end

  create_table "artworks", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "description",         limit: 255
    t.integer  "artist_id",           limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "artwork_id",          limit: 4
    t.integer  "preview_id",          limit: 4
    t.string   "local_file_location", limit: 255
    t.string   "bg_color",            limit: 255
  end

  create_table "assets", force: :cascade do |t|
    t.string   "file_file_name",       limit: 255
    t.string   "file_content_type",    limit: 255
    t.integer  "file_file_size",       limit: 4
    t.datetime "file_updated_at"
    t.string   "description",          limit: 255
    t.integer  "assetable_id",         limit: 4
    t.string   "assetable_type",       limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "allowed_content_type", limit: 255
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "sku",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "retail",                 default: false
  end

  add_index "brands", ["deleted_at"], name: "index_brands_on_deleted_at", using: :btree
  add_index "brands", ["retail"], name: "index_brands_on_retail", using: :btree

  create_table "colors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "sku",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "retail",                 default: false
    t.string   "hexcode",    limit: 255
  end

  add_index "colors", ["deleted_at"], name: "index_colors_on_deleted_at", using: :btree
  add_index "colors", ["retail"], name: "index_colors_on_retail", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 140,   default: ""
    t.text     "comment",          limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.string   "role",             limit: 255,   default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "coordinate_imprintables", force: :cascade do |t|
    t.integer  "coordinate_id",  limit: 4
    t.integer  "imprintable_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coordinate_imprintables", ["coordinate_id", "imprintable_id"], name: "coordinate_imprintable_index", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "name",        limit: 255
    t.string   "calculator",  limit: 255
    t.decimal  "value",                   precision: 10
    t.datetime "valid_until"
    t.datetime "valid_from"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "coupons", ["code"], name: "index_coupons_on_code", using: :btree

  create_table "customer_uploads", force: :cascade do |t|
    t.string   "filename",         limit: 255
    t.string   "url",              limit: 255
    t.integer  "quote_request_id", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.integer  "discountable_id",   limit: 4
    t.string   "discountable_type", limit: 255
    t.text     "reason",            limit: 65535
    t.string   "discount_method",   limit: 255
    t.string   "transaction_id",    limit: 255
    t.integer  "user_id",           limit: 4
    t.integer  "applicator_id",     limit: 4
    t.string   "applicator_type",   limit: 255
    t.decimal  "amount",                          precision: 10
    t.integer  "order_id",          limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "email_templates", force: :cascade do |t|
    t.string   "subject",        limit: 255
    t.string   "from",           limit: 255
    t.string   "bcc",            limit: 255
    t.string   "cc",             limit: 255
    t.text     "body",           limit: 65535
    t.datetime "deleted_at"
    t.string   "template_type",  limit: 255
    t.string   "name",           limit: 255
    t.text     "plaintext_body", limit: 65535
    t.string   "to",             limit: 255
  end

  create_table "emails", force: :cascade do |t|
    t.string   "subject",        limit: 255
    t.text     "body",           limit: 65535
    t.string   "to",             limit: 255
    t.string   "from",           limit: 255
    t.string   "cc",             limit: 255
    t.integer  "emailable_id",   limit: 4
    t.string   "emailable_type", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bcc",            limit: 255
    t.text     "plaintext_body", limit: 65535
    t.boolean  "freshdesk"
  end

  create_table "freshdesk_local_contacts", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "freshdesk_id", limit: 4
    t.string   "email",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imprint_method_imprintables", force: :cascade do |t|
    t.integer  "imprint_method_id", limit: 4
    t.integer  "imprintable_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "imprint_method_imprintables", ["imprintable_id", "imprint_method_id"], name: "imprint_method_imprintables_index", using: :btree

  create_table "imprint_method_ink_colors", force: :cascade do |t|
    t.integer  "imprint_method_id", limit: 4
    t.integer  "ink_color_id",      limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "imprint_methods", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deletable",              default: true
  end

  add_index "imprint_methods", ["deleted_at"], name: "index_imprint_methods_on_deleted_at", using: :btree

  create_table "imprintable_categories", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "imprintable_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imprintable_groups", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

  create_table "imprintable_imprintable_groups", force: :cascade do |t|
    t.integer "imprintable_id",       limit: 4
    t.integer "imprintable_group_id", limit: 4
    t.integer "tier",                 limit: 4
    t.boolean "default"
  end

  create_table "imprintable_photos", force: :cascade do |t|
    t.integer  "color_id",       limit: 4
    t.integer  "imprintable_id", limit: 4
    t.boolean  "default"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "imprintable_stores", force: :cascade do |t|
    t.integer  "imprintable_id", limit: 4
    t.integer  "store_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "imprintable_stores", ["imprintable_id", "store_id"], name: "index_imprintable_stores_on_imprintable_id_and_store_id", using: :btree

  create_table "imprintable_variants", force: :cascade do |t|
    t.integer  "imprintable_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size_id",        limit: 4
    t.integer  "color_id",       limit: 4
    t.datetime "deleted_at"
    t.decimal  "weight",                   precision: 10, scale: 1
  end

  add_index "imprintable_variants", ["deleted_at"], name: "index_imprintable_variants_on_deleted_at", using: :btree

  create_table "imprintables", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flashable"
    t.text     "special_considerations", limit: 65535
    t.boolean  "polyester"
    t.string   "sizing_category",        limit: 255
    t.datetime "deleted_at"
    t.text     "proofing_template_name", limit: 65535
    t.string   "material",               limit: 255
    t.boolean  "standard_offering"
    t.string   "main_supplier",          limit: 255
    t.string   "supplier_link",          limit: 255
    t.string   "weight",                 limit: 255
    t.decimal  "base_price",                           precision: 10, scale: 2
    t.decimal  "xxl_price",                            precision: 10, scale: 2
    t.decimal  "xxxl_price",                           precision: 10, scale: 2
    t.decimal  "xxxxl_price",                          precision: 10, scale: 2
    t.decimal  "xxxxxl_price",                         precision: 10, scale: 2
    t.decimal  "xxxxxxl_price",                        precision: 10, scale: 2
    t.string   "style_name",             limit: 255
    t.string   "style_catalog_no",       limit: 255
    t.text     "style_description",      limit: 65535
    t.string   "sku",                    limit: 255
    t.boolean  "retail",                                                        default: false
    t.integer  "brand_id",               limit: 4
    t.decimal  "max_imprint_width",                    precision: 8,  scale: 2
    t.decimal  "max_imprint_height",                   precision: 8,  scale: 2
    t.string   "common_name",            limit: 255
    t.decimal  "xxl_upcharge",                         precision: 10, scale: 2
    t.decimal  "xxxl_upcharge",                        precision: 10, scale: 2
    t.decimal  "xxxxl_upcharge",                       precision: 10, scale: 2
    t.decimal  "xxxxxl_upcharge",                      precision: 10, scale: 2
    t.decimal  "xxxxxxl_upcharge",                     precision: 10, scale: 2
    t.decimal  "base_upcharge",                        precision: 10, scale: 2
    t.boolean  "discontinued",                                                  default: false
    t.string   "water_resistance_level", limit: 255
    t.string   "sleeve_type",            limit: 255
    t.string   "sleeve_length",          limit: 255
    t.string   "neck_style",             limit: 255
    t.string   "neck_size",              limit: 255
    t.string   "fabric_type",            limit: 255
    t.boolean  "is_stain_resistant"
    t.string   "fit_type",               limit: 255
    t.string   "fabric_wash",            limit: 255
    t.string   "department_name",        limit: 255
    t.string   "chest_size",             limit: 255
    t.decimal  "package_height",                       precision: 10
    t.decimal  "package_width",                        precision: 10
    t.decimal  "package_length",                       precision: 10
    t.string   "tag",                    limit: 255,                            default: "Not Specified"
    t.string   "marketplace_name",       limit: 255
  end

  add_index "imprintables", ["deleted_at"], name: "index_imprintables_on_deleted_at", using: :btree
  add_index "imprintables", ["main_supplier"], name: "index_imprintables_on_main_supplier", using: :btree

  create_table "imprints", force: :cascade do |t|
    t.integer  "print_location_id", limit: 4
    t.integer  "job_id",            limit: 4
    t.decimal  "ideal_width",                     precision: 10
    t.decimal  "ideal_height",                    precision: 10
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_name_number"
    t.integer  "name_number_id",    limit: 4
    t.string   "name_format",       limit: 255
    t.string   "number_format",     limit: 255
    t.text     "description",       limit: 65535
    t.integer  "softwear_prod_id",  limit: 4
  end

  create_table "in_store_credits", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "customer_first_name", limit: 255
    t.string   "customer_last_name",  limit: 255
    t.string   "customer_email",      limit: 255
    t.decimal  "amount",                            precision: 10
    t.text     "description",         limit: 65535
    t.integer  "user_id",             limit: 4
    t.datetime "valid_until"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "ink_colors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "custom"
  end

  add_index "ink_colors", ["deleted_at"], name: "index_ink_colors_on_deleted_at", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description",      limit: 65535
    t.integer  "jobbable_id",      limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "collapsed"
    t.string   "jobbable_type",    limit: 255
    t.integer  "softwear_prod_id", limit: 4
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree

  create_table "line_item_groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "quote_id",    limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_item_groups", ["quote_id"], name: "index_line_item_groups_on_quote_id", using: :btree

  create_table "line_item_templates", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.string   "url",         limit: 255
    t.decimal  "unit_price",                precision: 10, scale: 2
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.integer  "quantity",                limit: 4
    t.boolean  "taxable",                                                        default: true
    t.text     "description",             limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",                            precision: 10, scale: 2
    t.integer  "line_itemable_id",        limit: 4
    t.string   "line_itemable_type",      limit: 255
    t.string   "url",                     limit: 255
    t.decimal  "decoration_price",                      precision: 10, scale: 2
    t.decimal  "imprintable_price",                     precision: 10, scale: 2
    t.integer  "tier",                    limit: 4
    t.integer  "sort_order",              limit: 4
    t.integer  "imprintable_object_id",   limit: 4
    t.string   "imprintable_object_type", limit: 255
  end

  add_index "line_items", ["line_itemable_id", "line_itemable_type"], name: "index_line_items_on_line_itemable_id_and_line_itemable_type", using: :btree

  create_table "name_numbers", force: :cascade do |t|
    t.string  "name",                   limit: 255
    t.string  "number",                 limit: 255
    t.integer "imprint_id",             limit: 4
    t.integer "imprintable_variant_id", limit: 4
  end

  create_table "order_quotes", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.integer  "quote_id",   limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "email",                     limit: 255
    t.string   "firstname",                 limit: 255
    t.string   "lastname",                  limit: 255
    t.string   "company",                   limit: 255
    t.string   "twitter",                   limit: 255
    t.string   "name",                      limit: 255
    t.string   "po",                        limit: 255
    t.datetime "in_hand_by"
    t.string   "terms",                     limit: 255
    t.boolean  "tax_exempt"
    t.string   "tax_id_number",             limit: 255
    t.string   "delivery_method",           limit: 255
    t.datetime "deleted_at"
    t.string   "phone_number",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission_amount",                     precision: 10, scale: 2
    t.integer  "store_id",                  limit: 4
    t.integer  "salesperson_id",            limit: 4
    t.decimal  "shipping_price",                        precision: 10, scale: 2, default: 0.0
    t.string   "invoice_state",             limit: 255
    t.string   "production_state",          limit: 255
    t.string   "notification_state",        limit: 255
    t.integer  "freshdesk_proof_ticket_id", limit: 4
    t.integer  "softwear_prod_id",          limit: 4
  end

  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",          limit: 4
    t.integer  "salesperson_id",    limit: 4
    t.integer  "store_id",          limit: 4
    t.boolean  "refunded"
    t.decimal  "amount",                          precision: 10, scale: 2
    t.text     "refund_reason",     limit: 65535
    t.datetime "deleted_at"
    t.string   "cc_invoice_no",     limit: 255
    t.string   "cc_batch_no",       limit: 255
    t.string   "check_dl_no",       limit: 255
    t.string   "check_phone_no",    limit: 255
    t.string   "pp_transaction_id", limit: 255
    t.integer  "payment_method",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "t_name",            limit: 255
    t.string   "t_company_name",    limit: 255
    t.string   "tf_number",         limit: 255
    t.text     "t_description",     limit: 65535
  end

  create_table "platen_hoops", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.decimal  "max_width",              precision: 10, scale: 2
    t.decimal  "max_height",             precision: 10, scale: 2
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "print_location_imprintables", force: :cascade do |t|
    t.integer  "imprintable_id",       limit: 4
    t.integer  "print_location_id",    limit: 4
    t.decimal  "max_imprint_width",              precision: 10
    t.decimal  "max_imprint_height",             precision: 10
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "ideal_imprint_width",            precision: 10, scale: 2
    t.decimal  "ideal_imprint_height",           precision: 10, scale: 2
    t.integer  "platen_hoop_id",       limit: 4
  end

  create_table "print_locations", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "imprint_method_id", limit: 4
    t.decimal  "max_height",                    precision: 8, scale: 2
    t.decimal  "max_width",                     precision: 8, scale: 2
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "print_locations", ["deleted_at"], name: "index_print_locations_on_deleted_at", using: :btree
  add_index "print_locations", ["imprint_method_id"], name: "index_print_locations_on_imprint_method_id", using: :btree

  create_table "proofs", force: :cascade do |t|
    t.string   "status",      limit: 255
    t.integer  "order_id",    limit: 4
    t.datetime "approve_by"
    t.datetime "approved_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id",      limit: 4
  end

  create_table "quote_request_quotes", force: :cascade do |t|
    t.integer  "quote_id",         limit: 4
    t.integer  "quote_request_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_requests", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "email",                     limit: 255
    t.string   "approx_quantity",           limit: 255
    t.datetime "date_needed"
    t.text     "description",               limit: 65535
    t.string   "source",                    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "salesperson_id",            limit: 4
    t.string   "status",                    limit: 255
    t.string   "reason",                    limit: 255
    t.string   "phone_number",              limit: 255
    t.string   "organization",              limit: 255
    t.integer  "insightly_contact_id",      limit: 4
    t.integer  "insightly_organisation_id", limit: 4
    t.integer  "freshdesk_contact_id",      limit: 4
    t.string   "freshdesk_ticket_id",       limit: 255
  end

  create_table "quotes", force: :cascade do |t|
    t.string   "email",                            limit: 255
    t.string   "phone_number",                     limit: 255
    t.string   "first_name",                       limit: 255
    t.string   "last_name",                        limit: 255
    t.string   "company",                          limit: 255
    t.string   "twitter",                          limit: 255
    t.string   "name",                             limit: 255
    t.datetime "valid_until_date"
    t.datetime "estimated_delivery_date"
    t.integer  "salesperson_id",                   limit: 4
    t.integer  "store_id",                         limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "shipping",                                     precision: 10, scale: 2
    t.string   "quote_source",                     limit: 255
    t.datetime "initialized_at"
    t.string   "freshdesk_ticket_id",              limit: 255
    t.boolean  "informal"
    t.integer  "insightly_category_id",            limit: 4
    t.integer  "insightly_probability",            limit: 4
    t.decimal  "insightly_value",                              precision: 10, scale: 2
    t.integer  "insightly_pipeline_id",            limit: 4
    t.integer  "insightly_opportunity_id",         limit: 4
    t.integer  "insightly_bid_tier_id",            limit: 4
    t.boolean  "is_rushed"
    t.integer  "qty",                              limit: 4
    t.boolean  "deadline_is_specified"
    t.integer  "insightly_opportunity_profile_id", limit: 4
    t.decimal  "insightly_bid_amount",                         precision: 10, scale: 2
    t.integer  "insightly_whos_responsible_id",    limit: 4
  end

  create_table "sample_locations", force: :cascade do |t|
    t.integer "imprintable_id", limit: 4
    t.integer "store_id",       limit: 4
  end

  create_table "search_boolean_filters", force: :cascade do |t|
    t.string  "field",  limit: 255
    t.boolean "negate"
    t.boolean "value"
  end

  create_table "search_date_filters", force: :cascade do |t|
    t.string   "field",      limit: 255
    t.boolean  "negate"
    t.datetime "value"
    t.string   "comparator", limit: 1
  end

  create_table "search_filter_groups", force: :cascade do |t|
    t.boolean "all"
  end

  create_table "search_filters", force: :cascade do |t|
    t.integer "filter_holder_id",   limit: 4
    t.string  "filter_holder_type", limit: 255
    t.integer "filter_type_id",     limit: 4
    t.string  "filter_type_type",   limit: 255
  end

  create_table "search_nil_filters", force: :cascade do |t|
    t.string  "field",  limit: 255
    t.boolean "negate"
  end

  create_table "search_number_filters", force: :cascade do |t|
    t.string  "field",      limit: 255
    t.boolean "negate"
    t.decimal "value",                  precision: 10, scale: 2
    t.string  "comparator", limit: 1
  end

  create_table "search_phrase_filters", force: :cascade do |t|
    t.string  "field",  limit: 255
    t.boolean "negate"
    t.string  "value",  limit: 255
  end

  create_table "search_queries", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_query_fields", force: :cascade do |t|
    t.integer "query_model_id", limit: 4
    t.string  "name",           limit: 255
    t.decimal "boost",                      precision: 10, scale: 2
    t.integer "phrase",         limit: 4
  end

  create_table "search_query_models", force: :cascade do |t|
    t.integer "query_id",         limit: 4
    t.string  "name",             limit: 255
    t.string  "default_fulltext", limit: 255
  end

  create_table "search_reference_filters", force: :cascade do |t|
    t.string  "field",      limit: 255
    t.boolean "negate"
    t.integer "value_id",   limit: 4
    t.string  "value_type", limit: 255
  end

  create_table "search_string_filters", force: :cascade do |t|
    t.string  "field",  limit: 255
    t.boolean "negate"
    t.string  "value",  limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "val",           limit: 255
    t.string   "encrypted_val", limit: 255
    t.boolean  "encrypted"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "shipping_method_id", limit: 4
    t.integer  "shipped_by_id",      limit: 4
    t.integer  "shippable_id",       limit: 4
    t.string   "shippable_type",     limit: 255
    t.decimal  "shipping_cost",                    precision: 10, scale: 2
    t.datetime "shipped_at"
    t.string   "tracking_number",    limit: 255
    t.string   "status",             limit: 255
    t.string   "name",               limit: 255
    t.string   "company",            limit: 255
    t.string   "attn",               limit: 255
    t.string   "address_1",          limit: 255
    t.string   "address_2",          limit: 255
    t.string   "address_3",          limit: 255
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.string   "zipcode",            limit: 255
    t.string   "country",            limit: 255
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.text     "notes",              limit: 65535
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "tracking_url", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_methods", ["deleted_at"], name: "index_shipping_methods_on_deleted_at", using: :btree

  create_table "sizes", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "display_value",          limit: 255
    t.string   "sku",                    limit: 255
    t.integer  "sort_order",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "imprintable_variant_id", limit: 4
    t.datetime "deleted_at"
    t.boolean  "retail",                             default: false
  end

  add_index "sizes", ["deleted_at"], name: "index_sizes_on_deleted_at", using: :btree
  add_index "sizes", ["imprintable_variant_id"], name: "size_imprintable_variant_id_ix", using: :btree
  add_index "sizes", ["retail"], name: "index_sizes_on_retail", using: :btree

  create_table "stores", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "deleted_at",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_1",   limit: 255
    t.string   "address_2",   limit: 255
    t.string   "city",        limit: 255
    t.string   "state",       limit: 255
    t.string   "zipcode",     limit: 255
    t.string   "country",     limit: 255
    t.string   "phone",       limit: 255
    t.string   "sales_email", limit: 255
    t.integer  "logo_id",     limit: 4
  end

  add_index "stores", ["deleted_at"], name: "index_stores_on_deleted_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                        limit: 255, default: "", null: false
    t.string   "encrypted_password",           limit: 255, default: "", null: false
    t.string   "reset_password_token",         limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",           limit: 255
    t.string   "last_sign_in_ip",              limit: 255
    t.string   "confirmation_token",           limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",            limit: 255
    t.integer  "failed_attempts",              limit: 4,   default: 0,  null: false
    t.string   "unlock_token",                 limit: 255
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
    t.datetime "deleted_at"
    t.integer  "store_id",                     limit: 4
    t.string   "authentication_token",         limit: 255
    t.string   "freshdesk_email",              limit: 255
    t.string   "freshdesk_password",           limit: 255
    t.string   "encrypted_freshdesk_password", limit: 255
    t.string   "insightly_api_key",            limit: 255
    t.integer  "profile_picture_id",           limit: 4
    t.integer  "signature_id",                 limit: 4
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "warning_emails", force: :cascade do |t|
    t.string  "model",     limit: 255
    t.decimal "minutes",               precision: 10, scale: 2
    t.string  "recipient", limit: 255
    t.string  "url",       limit: 255
  end

  create_table "warnings", force: :cascade do |t|
    t.integer  "warnable_id",   limit: 4
    t.string   "warnable_type", limit: 255
    t.string   "source",        limit: 255
    t.text     "message",       limit: 65535
    t.datetime "dismissed_at"
    t.integer  "dismisser_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

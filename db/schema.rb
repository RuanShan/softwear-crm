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

ActiveRecord::Schema.define(version: 20160509160931) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 191
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 191
    t.string   "key",            limit: 191
    t.text     "parameters",     limit: 16777215
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "admin_proofs", force: :cascade do |t|
    t.integer  "order_id",      limit: 4
    t.string   "file_url",      limit: 191
    t.string   "thumbnail_url", limit: 191
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "name",          limit: 191
    t.text     "description",   limit: 65535
  end

  add_index "admin_proofs", ["order_id"], name: "index_admin_proofs_on_order_id", using: :btree

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
    t.text     "description",             limit: 16777215
    t.integer  "artist_id",               limit: 4
    t.integer  "imprint_method_id",       limit: 4
    t.integer  "print_location_id",       limit: 4
    t.integer  "salesperson_id",          limit: 4
    t.datetime "deadline"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "priority",                limit: 191
    t.string   "state",                   limit: 191
    t.boolean  "reorder"
    t.integer  "approved_by_id",          limit: 4
    t.boolean  "exact_recreation"
    t.decimal  "amount_paid_for_artwork",                  precision: 10, scale: 2, default: 0.0
    t.integer  "softwear_prod_id",        limit: 4
  end

  create_table "artworks", force: :cascade do |t|
    t.string   "name",                limit: 191
    t.string   "description",         limit: 191
    t.integer  "artist_id",           limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "artwork_id",          limit: 4
    t.integer  "preview_id",          limit: 4
    t.string   "local_file_location", limit: 191
    t.string   "bg_color",            limit: 191
  end

  create_table "assets", force: :cascade do |t|
    t.string   "file_file_name",       limit: 191
    t.string   "file_content_type",    limit: 191
    t.integer  "file_file_size",       limit: 4
    t.datetime "file_updated_at"
    t.text     "description",          limit: 16777215
    t.integer  "assetable_id",         limit: 4
    t.string   "assetable_type",       limit: 191
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "allowed_content_type", limit: 191
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "sku",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "retail",                 default: false
  end

  add_index "brands", ["deleted_at"], name: "index_brands_on_deleted_at", using: :btree
  add_index "brands", ["retail"], name: "index_brands_on_retail", using: :btree

  create_table "colors", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "sku",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "retail",                 default: false
    t.string   "hexcode",    limit: 191
    t.string   "map",        limit: 191
  end

  add_index "colors", ["deleted_at"], name: "index_colors_on_deleted_at", using: :btree
  add_index "colors", ["retail"], name: "index_colors_on_retail", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 191
    t.text     "comment",          limit: 16777215
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 191
    t.integer  "user_id",          limit: 4
    t.string   "role",             limit: 191
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

  create_table "costs", force: :cascade do |t|
    t.string   "costable_type", limit: 191
    t.string   "costable_id",   limit: 191
    t.string   "type",          limit: 191
    t.text     "description",   limit: 65535
    t.integer  "owner_id",      limit: 4
    t.decimal  "time",                        precision: 10, scale: 2
    t.decimal  "amount",                      precision: 10, scale: 2
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "costs", ["costable_id"], name: "index_costs_on_costable_id", using: :btree
  add_index "costs", ["costable_type"], name: "index_costs_on_costable_type", using: :btree
  add_index "costs", ["owner_id"], name: "index_costs_on_owner_id", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "code",        limit: 191
    t.string   "name",        limit: 191
    t.string   "calculator",  limit: 191
    t.decimal  "value",                   precision: 10
    t.datetime "valid_until"
    t.datetime "valid_from"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "coupons", ["code"], name: "index_coupons_on_code", using: :btree

  create_table "crm_contacts", force: :cascade do |t|
    t.string   "first_name", limit: 191
    t.string   "last_name",  limit: 191
    t.string   "twitter",    limit: 191
    t.string   "state",      limit: 191
    t.integer  "tier",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "crm_contacts", ["first_name"], name: "index_crm_contacts_on_first_name", using: :btree
  add_index "crm_contacts", ["last_name"], name: "index_crm_contacts_on_last_name", using: :btree
  add_index "crm_contacts", ["state"], name: "index_crm_contacts_on_state", using: :btree
  add_index "crm_contacts", ["tier"], name: "index_crm_contacts_on_tier", using: :btree
  add_index "crm_contacts", ["twitter"], name: "index_crm_contacts_on_twitter", using: :btree

  create_table "crm_emails", force: :cascade do |t|
    t.string   "address",    limit: 191
    t.integer  "contact_id", limit: 4
    t.boolean  "primary"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "crm_emails", ["address"], name: "index_crm_emails_on_address", using: :btree

  create_table "crm_phones", force: :cascade do |t|
    t.string   "number",     limit: 191
    t.string   "extension",  limit: 191
    t.integer  "contact_id", limit: 4
    t.boolean  "primary"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "crm_phones", ["contact_id"], name: "index_crm_phones_on_contact_id", using: :btree
  add_index "crm_phones", ["number"], name: "index_crm_phones_on_number", using: :btree

  create_table "customer_uploads", force: :cascade do |t|
    t.string   "filename",         limit: 191
    t.string   "url",              limit: 191
    t.integer  "quote_request_id", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "deposits", force: :cascade do |t|
    t.decimal  "cash_included",                   precision: 10, scale: 2
    t.decimal  "check_included",                  precision: 10, scale: 2
    t.text     "difference_reason", limit: 65535
    t.string   "deposit_location",  limit: 191
    t.string   "deposit_id",        limit: 191
    t.integer  "depositor_id",      limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts", force: :cascade do |t|
    t.integer  "discountable_id",   limit: 4
    t.string   "discountable_type", limit: 191
    t.text     "reason",            limit: 16777215
    t.string   "discount_method",   limit: 191
    t.string   "transaction_id",    limit: 191
    t.integer  "user_id",           limit: 4
    t.integer  "applicator_id",     limit: 4
    t.string   "applicator_type",   limit: 191
    t.decimal  "amount",                             precision: 10, scale: 2
    t.integer  "order_id",          limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  create_table "email_templates", force: :cascade do |t|
    t.string   "subject",        limit: 191
    t.string   "from",           limit: 191
    t.string   "bcc",            limit: 191
    t.string   "cc",             limit: 191
    t.text     "body",           limit: 16777215
    t.datetime "deleted_at"
    t.string   "template_type",  limit: 191
    t.string   "name",           limit: 191
    t.text     "plaintext_body", limit: 16777215
    t.string   "to",             limit: 191
  end

  create_table "emails", force: :cascade do |t|
    t.string   "subject",        limit: 191
    t.text     "body",           limit: 16777215
    t.string   "to",             limit: 191
    t.string   "from",           limit: 191
    t.string   "cc",             limit: 191
    t.integer  "emailable_id",   limit: 4
    t.string   "emailable_type", limit: 191
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bcc",            limit: 191
    t.text     "plaintext_body", limit: 16777215
    t.boolean  "freshdesk"
  end

  create_table "fba_imprint_templates", force: :cascade do |t|
    t.integer "print_location_id",   limit: 4
    t.integer "fba_job_template_id", limit: 4
    t.text    "description",         limit: 65535
    t.integer "artwork_id",          limit: 4
  end

  add_index "fba_imprint_templates", ["fba_job_template_id"], name: "index_fba_imprint_templates_on_fba_job_template_id", using: :btree

  create_table "fba_job_template_imprints", force: :cascade do |t|
    t.integer  "fba_job_template_id", limit: 4
    t.integer  "imprint_id",          limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "fba_job_template_imprints", ["fba_job_template_id"], name: "index_fba_job_template_imprints_on_fba_job_template_id", using: :btree
  add_index "fba_job_template_imprints", ["imprint_id"], name: "index_fba_job_template_imprints_on_imprint_id", using: :btree

  create_table "fba_job_templates", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "job_name",   limit: 191
  end

  create_table "fba_products", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "sku",        limit: 191
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "fba_skus", force: :cascade do |t|
    t.integer  "fba_product_id",         limit: 4
    t.string   "sku",                    limit: 191
    t.integer  "imprintable_variant_id", limit: 4
    t.integer  "fba_job_template_id",    limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "fnsku",                  limit: 191
    t.string   "asin",                   limit: 191
  end

  add_index "fba_skus", ["fba_job_template_id"], name: "index_fba_skus_on_fba_job_template_id", using: :btree
  add_index "fba_skus", ["fba_product_id"], name: "index_fba_skus_on_fba_product_id", using: :btree
  add_index "fba_skus", ["imprintable_variant_id"], name: "index_fba_skus_on_imprintable_variant_id", using: :btree

  create_table "fba_spreadsheet_uploads", force: :cascade do |t|
    t.boolean  "done"
    t.text     "spreadsheet",       limit: 4294967295
    t.text     "processing_errors", limit: 65535
    t.string   "filename",          limit: 191
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "freshdesk_local_contacts", force: :cascade do |t|
    t.string   "name",         limit: 191
    t.integer  "freshdesk_id", limit: 4
    t.string   "email",        limit: 191
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
    t.string   "name",             limit: 191
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deletable",                    default: true
    t.boolean  "name_number"
    t.boolean  "requires_artwork"
  end

  add_index "imprint_methods", ["deleted_at"], name: "index_imprint_methods_on_deleted_at", using: :btree

  create_table "imprintable_categories", force: :cascade do |t|
    t.string   "name",           limit: 191
    t.integer  "imprintable_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imprintable_groups", force: :cascade do |t|
    t.string "name",        limit: 191
    t.text   "description", limit: 16777215
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
    t.integer  "imprintable_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size_id",          limit: 4
    t.integer  "color_id",         limit: 4
    t.datetime "deleted_at"
    t.decimal  "weight",                     precision: 10, scale: 1
    t.decimal  "last_cost_amount",           precision: 10, scale: 2
  end

  add_index "imprintable_variants", ["deleted_at"], name: "index_imprintable_variants_on_deleted_at", using: :btree

  create_table "imprintables", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flashable"
    t.text     "special_considerations", limit: 16777215
    t.boolean  "polyester"
    t.string   "sizing_category",        limit: 191
    t.datetime "deleted_at"
    t.text     "proofing_template_name", limit: 16777215
    t.string   "material",               limit: 191
    t.boolean  "standard_offering"
    t.string   "main_supplier",          limit: 191
    t.text     "supplier_link",          limit: 16777215
    t.string   "weight",                 limit: 191
    t.decimal  "base_price",                              precision: 10, scale: 2
    t.decimal  "xxl_price",                               precision: 10, scale: 2
    t.decimal  "xxxl_price",                              precision: 10, scale: 2
    t.decimal  "xxxxl_price",                             precision: 10, scale: 2
    t.decimal  "xxxxxl_price",                            precision: 10, scale: 2
    t.decimal  "xxxxxxl_price",                           precision: 10, scale: 2
    t.string   "style_name",             limit: 191
    t.string   "style_catalog_no",       limit: 191
    t.text     "style_description",      limit: 16777215
    t.string   "sku",                    limit: 191
    t.boolean  "retail",                                                           default: false
    t.integer  "brand_id",               limit: 4
    t.decimal  "max_imprint_width",                       precision: 8,  scale: 2
    t.decimal  "max_imprint_height",                      precision: 8,  scale: 2
    t.string   "common_name",            limit: 191
    t.decimal  "xxl_upcharge",                            precision: 10, scale: 2
    t.decimal  "xxxl_upcharge",                           precision: 10, scale: 2
    t.decimal  "xxxxl_upcharge",                          precision: 10, scale: 2
    t.decimal  "xxxxxl_upcharge",                         precision: 10, scale: 2
    t.decimal  "xxxxxxl_upcharge",                        precision: 10, scale: 2
    t.decimal  "base_upcharge",                           precision: 10, scale: 2
    t.boolean  "discontinued",                                                     default: false
    t.string   "water_resistance_level", limit: 191
    t.string   "sleeve_type",            limit: 191
    t.string   "sleeve_length",          limit: 191
    t.string   "neck_style",             limit: 191
    t.string   "neck_size",              limit: 191
    t.string   "fabric_type",            limit: 191
    t.boolean  "is_stain_resistant"
    t.string   "fit_type",               limit: 191
    t.string   "fabric_wash",            limit: 191
    t.string   "department_name",        limit: 191
    t.string   "chest_size",             limit: 191
    t.decimal  "package_height",                          precision: 10
    t.decimal  "package_width",                           precision: 10
    t.decimal  "package_length",                          precision: 10
    t.string   "tag",                    limit: 191
    t.string   "marketplace_name",       limit: 191
    t.string   "sizing_chart_url",       limit: 191
    t.integer  "sizing_chart_id",        limit: 4
  end

  add_index "imprintables", ["deleted_at"], name: "index_imprintables_on_deleted_at", using: :btree
  add_index "imprintables", ["main_supplier"], name: "index_imprintables_on_main_supplier", using: :btree

  create_table "imprints", force: :cascade do |t|
    t.integer  "print_location_id", limit: 4
    t.integer  "job_id",            limit: 4
    t.decimal  "ideal_width",                        precision: 10
    t.decimal  "ideal_height",                       precision: 10
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_name_number"
    t.integer  "name_number_id",    limit: 4
    t.string   "name_format",       limit: 191
    t.string   "number_format",     limit: 191
    t.text     "description",       limit: 16777215
    t.integer  "softwear_prod_id",  limit: 4
    t.boolean  "name_number"
  end

  create_table "in_store_credits", force: :cascade do |t|
    t.string   "name",                limit: 191
    t.string   "customer_first_name", limit: 191
    t.string   "customer_last_name",  limit: 191
    t.string   "customer_email",      limit: 191
    t.decimal  "amount",                               precision: 10, scale: 2
    t.text     "description",         limit: 16777215
    t.integer  "user_id",             limit: 4
    t.datetime "valid_until"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  create_table "ink_colors", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "custom"
  end

  add_index "ink_colors", ["deleted_at"], name: "index_ink_colors_on_deleted_at", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "name",                limit: 191
    t.text     "description",         limit: 16777215
    t.integer  "jobbable_id",         limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "collapsed"
    t.string   "jobbable_type",       limit: 191
    t.integer  "softwear_prod_id",    limit: 4
    t.integer  "sort_order",          limit: 4
    t.integer  "fba_job_template_id", limit: 4
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree
  add_index "jobs", ["fba_job_template_id"], name: "index_jobs_on_fba_job_template_id", using: :btree
  add_index "jobs", ["jobbable_id"], name: "index_jobs_jobbable_id", using: :btree
  add_index "jobs", ["jobbable_type"], name: "index_jobs_jobbable_type", using: :btree

  create_table "line_item_groups", force: :cascade do |t|
    t.string   "name",        limit: 191
    t.string   "description", limit: 191
    t.integer  "quote_id",    limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_item_groups", ["quote_id"], name: "index_line_item_groups_on_quote_id", using: :btree

  create_table "line_item_templates", force: :cascade do |t|
    t.string   "name",        limit: 191
    t.text     "description", limit: 16777215
    t.string   "url",         limit: 191
    t.decimal  "unit_price",                   precision: 10, scale: 2
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.string   "name",                    limit: 191
    t.integer  "quantity",                limit: 4
    t.boolean  "taxable",                                                           default: true
    t.text     "description",             limit: 16777215
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",                               precision: 10, scale: 2
    t.integer  "job_id",                  limit: 4
    t.string   "url",                     limit: 191
    t.decimal  "decoration_price",                         precision: 10, scale: 2
    t.decimal  "imprintable_price",                        precision: 10, scale: 2
    t.integer  "tier",                    limit: 4
    t.integer  "sort_order",              limit: 4
    t.integer  "imprintable_object_id",   limit: 4
    t.string   "imprintable_object_type", limit: 191
    t.decimal  "cost_amount",                              precision: 10, scale: 2
  end

  add_index "line_items", ["job_id"], name: "index_line_items_on_line_itemable_id_and_line_itemable_type", using: :btree

  create_table "name_numbers", force: :cascade do |t|
    t.string  "name",                   limit: 191
    t.string  "number",                 limit: 191
    t.integer "imprint_id",             limit: 4
    t.integer "imprintable_variant_id", limit: 4
  end

  create_table "old_users", force: :cascade do |t|
    t.string   "email",                        limit: 191
    t.string   "encrypted_password",           limit: 191
    t.string   "reset_password_token",         limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                limit: 4,   default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",           limit: 191
    t.string   "last_sign_in_ip",              limit: 191
    t.string   "confirmation_token",           limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",            limit: 191
    t.integer  "failed_attempts",              limit: 4,   default: 0, null: false
    t.string   "unlock_token",                 limit: 191
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                   limit: 191
    t.string   "last_name",                    limit: 191
    t.datetime "deleted_at"
    t.integer  "store_id",                     limit: 4
    t.string   "authentication_token",         limit: 191
    t.string   "freshdesk_email",              limit: 191
    t.string   "freshdesk_password",           limit: 191
    t.string   "encrypted_freshdesk_password", limit: 191
    t.string   "insightly_api_key",            limit: 191
    t.integer  "profile_picture_id",           limit: 4
    t.integer  "signature_id",                 limit: 4
  end

  add_index "old_users", ["authentication_token"], name: "index_old_users_on_authentication_token", using: :btree
  add_index "old_users", ["confirmation_token"], name: "index_old_users_on_confirmation_token", unique: true, using: :btree
  add_index "old_users", ["deleted_at"], name: "index_old_users_on_deleted_at", using: :btree
  add_index "old_users", ["email"], name: "index_old_users_on_email", unique: true, using: :btree
  add_index "old_users", ["reset_password_token"], name: "index_old_users_on_reset_password_token", unique: true, using: :btree
  add_index "old_users", ["unlock_token"], name: "index_old_users_on_unlock_token", unique: true, using: :btree

  create_table "order_quotes", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.integer  "quote_id",   limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "deprecated_email",          limit: 191
    t.string   "deprecated_firstname",      limit: 191
    t.string   "deprecated_lastname",       limit: 191
    t.string   "company",                   limit: 191
    t.string   "deprecated_twitter",        limit: 191
    t.string   "name",                      limit: 191
    t.string   "po",                        limit: 191
    t.datetime "in_hand_by"
    t.string   "terms",                     limit: 191
    t.boolean  "tax_exempt"
    t.string   "tax_id_number",             limit: 191
    t.string   "delivery_method",           limit: 191
    t.datetime "deleted_at"
    t.string   "deprecated_phone_number",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "commission_amount",                          precision: 10, scale: 2
    t.integer  "store_id",                  limit: 4
    t.integer  "salesperson_id",            limit: 4
    t.decimal  "shipping_price",                             precision: 10, scale: 2, default: 0.0
    t.string   "invoice_state",             limit: 191
    t.string   "production_state",          limit: 191
    t.string   "notification_state",        limit: 191
    t.integer  "freshdesk_proof_ticket_id", limit: 4
    t.integer  "softwear_prod_id",          limit: 4
    t.string   "artwork_state",             limit: 191
    t.string   "customer_key",              limit: 191
    t.text     "invoice_reject_reason",     limit: 16777215
    t.decimal  "subtotal",                                   precision: 10, scale: 2
    t.decimal  "taxable_total",                              precision: 10, scale: 2
    t.decimal  "discount_total",                             precision: 10, scale: 2
    t.decimal  "payment_total",                              precision: 10, scale: 2
    t.boolean  "imported_from_admin"
    t.string   "payment_state",             limit: 191
    t.string   "phone_number_extension",    limit: 191
    t.boolean  "canceled"
    t.decimal  "tax_rate",                                   precision: 10, scale: 4
    t.decimal  "fee",                                        precision: 10, scale: 4
    t.string   "fee_description",           limit: 191
    t.integer  "contact_id",                limit: 4
  end

  add_index "orders", ["contact_id"], name: "index_orders_on_contact_id", using: :btree
  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree

  create_table "payment_drop_payments", force: :cascade do |t|
    t.integer  "payment_id",      limit: 4
    t.integer  "payment_drop_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "payment_drop_payments", ["payment_drop_id"], name: "index_payment_drop_payments_on_payment_drop_id", using: :btree
  add_index "payment_drop_payments", ["payment_id"], name: "index_payment_drop_payments_on_payment_id", using: :btree

  create_table "payment_drops", force: :cascade do |t|
    t.decimal  "cash_included",                      precision: 10, scale: 2
    t.text     "difference_reason", limit: 16777215
    t.integer  "salesperson_id",    limit: 4
    t.integer  "store_id",          limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.decimal  "check_included",                     precision: 10, scale: 2
    t.integer  "deposit_id",        limit: 4
  end

  add_index "payment_drops", ["salesperson_id"], name: "index_payment_drops_on_salesperson_id", using: :btree
  add_index "payment_drops", ["store_id"], name: "index_payment_drops_on_store_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",           limit: 4
    t.integer  "salesperson_id",     limit: 4
    t.integer  "store_id",           limit: 4
    t.decimal  "amount",                              precision: 10, scale: 2
    t.text     "refund_reason",      limit: 16777215
    t.datetime "deleted_at"
    t.string   "cc_invoice_no",      limit: 191
    t.string   "cc_batch_no",        limit: 191
    t.string   "check_dl_no",        limit: 191
    t.string   "check_phone_no",     limit: 191
    t.string   "pp_transaction_id",  limit: 191
    t.integer  "payment_method",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "t_name",             limit: 191
    t.string   "t_company_name",     limit: 191
    t.string   "tf_number",          limit: 191
    t.text     "t_description",      limit: 16777215
    t.string   "cc_name",            limit: 191
    t.string   "cc_company",         limit: 191
    t.string   "cc_number",          limit: 191
    t.string   "cc_type",            limit: 191
    t.string   "cc_transaction",     limit: 191
    t.text     "retail_description", limit: 16777215
    t.decimal  "sales_tax_amount",                    precision: 10, scale: 2
    t.string   "pp_ref",             limit: 191
    t.string   "address1",           limit: 191
    t.string   "city",               limit: 191
    t.string   "state",              limit: 191
    t.string   "country",            limit: 191
    t.string   "zipcode",            limit: 191
  end

  create_table "platen_hoops", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.decimal  "max_width",              precision: 10, scale: 2
    t.decimal  "max_height",             precision: 10, scale: 2
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "pricing_imprint_option_values", force: :cascade do |t|
    t.integer "imprint_id",              limit: 4
    t.integer "pricing_option_value_id", limit: 4
  end

  add_index "pricing_imprint_option_values", ["imprint_id"], name: "index_pricing_imprint_option_values_on_imprint_id", using: :btree
  add_index "pricing_imprint_option_values", ["pricing_option_value_id"], name: "index_pricing_imprint_option_values_on_pricing_option_value_id", using: :btree

  create_table "pricing_option_types", force: :cascade do |t|
    t.integer "imprint_method_id", limit: 4
    t.string  "name",              limit: 191
  end

  add_index "pricing_option_types", ["imprint_method_id"], name: "index_pricing_option_types_on_imprint_method_id", using: :btree

  create_table "pricing_option_values", force: :cascade do |t|
    t.integer "option_type_id", limit: 4
    t.string  "value",          limit: 191
  end

  add_index "pricing_option_values", ["option_type_id"], name: "index_pricing_option_values_on_option_type_id", using: :btree

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
    t.string   "name",              limit: 191
    t.integer  "imprint_method_id", limit: 4
    t.decimal  "max_height",                    precision: 8, scale: 2
    t.decimal  "max_width",                     precision: 8, scale: 2
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "popularity",        limit: 4,                           default: 0
  end

  add_index "print_locations", ["deleted_at"], name: "index_print_locations_on_deleted_at", using: :btree
  add_index "print_locations", ["imprint_method_id"], name: "index_print_locations_on_imprint_method_id", using: :btree

  create_table "proofs", force: :cascade do |t|
    t.string   "state",       limit: 191
    t.integer  "order_id",    limit: 4
    t.datetime "approve_by"
    t.datetime "approved_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id",      limit: 4
  end

  create_table "quote_request_imprintables", force: :cascade do |t|
    t.integer  "quote_request_id", limit: 4
    t.integer  "imprintable_id",   limit: 4
    t.integer  "quantity",         limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "quote_request_quotes", force: :cascade do |t|
    t.integer  "quote_id",         limit: 4
    t.integer  "quote_request_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quote_requests", force: :cascade do |t|
    t.string   "name",                      limit: 191
    t.string   "email",                     limit: 191
    t.string   "approx_quantity",           limit: 191
    t.datetime "date_needed"
    t.text     "description",               limit: 16777215
    t.string   "source",                    limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "salesperson_id",            limit: 4
    t.string   "status",                    limit: 191
    t.string   "reason",                    limit: 191
    t.string   "phone_number",              limit: 191
    t.string   "organization",              limit: 191
    t.integer  "insightly_contact_id",      limit: 4
    t.integer  "insightly_organisation_id", limit: 4
    t.integer  "freshdesk_contact_id",      limit: 4
    t.string   "freshdesk_ticket_id",       limit: 191
    t.string   "domain",                    limit: 191
    t.string   "ip_address",                limit: 191
  end

  create_table "quotes", force: :cascade do |t|
    t.string   "deprecated_email",                 limit: 191
    t.string   "deprecated_phone_number",          limit: 191
    t.string   "deprecated_first_name",            limit: 191
    t.string   "deprecated_last_name",             limit: 191
    t.string   "company",                          limit: 191
    t.string   "twitter",                          limit: 191
    t.string   "name",                             limit: 191
    t.datetime "valid_until_date"
    t.datetime "estimated_delivery_date"
    t.integer  "salesperson_id",                   limit: 4
    t.integer  "store_id",                         limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "shipping",                                     precision: 10, scale: 2
    t.string   "quote_source",                     limit: 191
    t.datetime "initialized_at"
    t.string   "freshdesk_ticket_id",              limit: 191
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
    t.string   "state",                            limit: 191
    t.integer  "contact_id",                       limit: 4
  end

  create_table "sample_locations", force: :cascade do |t|
    t.integer "imprintable_id", limit: 4
    t.integer "store_id",       limit: 4
  end

  create_table "search_boolean_filters", force: :cascade do |t|
    t.string  "field",  limit: 191
    t.boolean "negate"
    t.boolean "value"
  end

  create_table "search_date_filters", force: :cascade do |t|
    t.string   "field",      limit: 191
    t.boolean  "negate"
    t.datetime "value"
    t.string   "comparator", limit: 191
  end

  create_table "search_filter_groups", force: :cascade do |t|
    t.boolean "all"
  end

  create_table "search_filters", force: :cascade do |t|
    t.integer "filter_holder_id",   limit: 4
    t.string  "filter_holder_type", limit: 191
    t.integer "filter_type_id",     limit: 4
    t.string  "filter_type_type",   limit: 191
  end

  create_table "search_nil_filters", force: :cascade do |t|
    t.string  "field",  limit: 191
    t.boolean "negate"
  end

  create_table "search_number_filters", force: :cascade do |t|
    t.string  "field",      limit: 191
    t.boolean "negate"
    t.decimal "value",                  precision: 10, scale: 2
    t.string  "comparator", limit: 191
  end

  create_table "search_phrase_filters", force: :cascade do |t|
    t.string  "field",  limit: 191
    t.boolean "negate"
    t.string  "value",  limit: 191
  end

  create_table "search_queries", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_query_fields", force: :cascade do |t|
    t.integer "query_model_id", limit: 4
    t.string  "name",           limit: 191
    t.decimal "boost",                      precision: 10, scale: 2
    t.integer "phrase",         limit: 4
  end

  create_table "search_query_models", force: :cascade do |t|
    t.integer "query_id",         limit: 4
    t.string  "name",             limit: 191
    t.string  "default_fulltext", limit: 191
  end

  create_table "search_reference_filters", force: :cascade do |t|
    t.string  "field",      limit: 191
    t.boolean "negate"
    t.integer "value_id",   limit: 4
    t.string  "value_type", limit: 191
  end

  create_table "search_sort_filters", force: :cascade do |t|
    t.string  "field",  limit: 191
    t.boolean "negate"
    t.string  "value",  limit: 191
  end

  create_table "search_string_filters", force: :cascade do |t|
    t.string  "field",  limit: 191
    t.boolean "negate"
    t.string  "value",  limit: 191
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 191
    t.text     "data",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "name",          limit: 191
    t.string   "val",           limit: 191
    t.string   "encrypted_val", limit: 191
    t.boolean  "encrypted"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "shipping_method_id", limit: 4
    t.integer  "shipped_by_id",      limit: 4
    t.integer  "shippable_id",       limit: 4
    t.string   "shippable_type",     limit: 191
    t.decimal  "shipping_cost",                       precision: 10, scale: 2
    t.datetime "shipped_at"
    t.string   "tracking_number",    limit: 191
    t.string   "status",             limit: 191
    t.string   "name",               limit: 191
    t.string   "company",            limit: 191
    t.string   "attn",               limit: 191
    t.string   "address_1",          limit: 191
    t.string   "address_2",          limit: 191
    t.string   "address_3",          limit: 191
    t.string   "city",               limit: 191
    t.string   "state",              limit: 191
    t.string   "zipcode",            limit: 191
    t.string   "country",            limit: 191
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.text     "notes",              limit: 16777215
    t.decimal  "time_in_transit",                     precision: 10, scale: 2
    t.integer  "softwear_prod_id",   limit: 4
    t.string   "softwear_prod_type", limit: 191
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string   "name",         limit: 191
    t.string   "tracking_url", limit: 191
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "popularity",   limit: 4,   default: 0
  end

  add_index "shipping_methods", ["deleted_at"], name: "index_shipping_methods_on_deleted_at", using: :btree

  create_table "sizes", force: :cascade do |t|
    t.string   "name",                   limit: 191
    t.string   "display_value",          limit: 191
    t.string   "sku",                    limit: 191
    t.integer  "sort_order",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "imprintable_variant_id", limit: 4
    t.datetime "deleted_at"
    t.boolean  "retail",                             default: false
    t.string   "upcharge_group",         limit: 191
  end

  add_index "sizes", ["deleted_at"], name: "index_sizes_on_deleted_at", using: :btree
  add_index "sizes", ["imprintable_variant_id"], name: "size_imprintable_variant_id_ix", using: :btree
  add_index "sizes", ["retail"], name: "index_sizes_on_retail", using: :btree

  create_table "stores", force: :cascade do |t|
    t.string   "name",        limit: 191
    t.string   "deleted_at",  limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_1",   limit: 191
    t.string   "address_2",   limit: 191
    t.string   "city",        limit: 191
    t.string   "state",       limit: 191
    t.string   "zipcode",     limit: 191
    t.string   "country",     limit: 191
    t.string   "phone",       limit: 191
    t.string   "sales_email", limit: 191
    t.integer  "logo_id",     limit: 4
  end

  add_index "stores", ["deleted_at"], name: "index_stores_on_deleted_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 191
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 191
    t.string   "context",       limit: 191
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 191
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_attributes", force: :cascade do |t|
    t.integer "user_id",                      limit: 4
    t.integer "store_id",                     limit: 4
    t.string  "freshdesk_email",              limit: 191
    t.string  "freshdesk_password",           limit: 191
    t.string  "encrypted_freshdesk_password", limit: 191
    t.string  "insightly_api_key",            limit: 191
    t.integer "signature_id",                 limit: 4
  end

  add_index "user_attributes", ["user_id"], name: "index_user_attributes_on_user_id", using: :btree

  create_table "warning_emails", force: :cascade do |t|
    t.string  "model",     limit: 191
    t.decimal "minutes",               precision: 10, scale: 2
    t.string  "recipient", limit: 191
    t.string  "url",       limit: 191
  end

  create_table "warnings", force: :cascade do |t|
    t.integer  "warnable_id",   limit: 4
    t.string   "warnable_type", limit: 191
    t.string   "source",        limit: 191
    t.text     "message",       limit: 16777215
    t.datetime "dismissed_at"
    t.integer  "dismisser_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "fba_job_template_imprints", "fba_job_templates"
  add_foreign_key "fba_job_template_imprints", "imprints"
  add_foreign_key "fba_skus", "fba_job_templates"
  add_foreign_key "fba_skus", "fba_products"
  add_foreign_key "fba_skus", "imprintable_variants"
  add_foreign_key "jobs", "fba_job_templates"
end

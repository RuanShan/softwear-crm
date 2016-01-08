class StoreStringsAs4ByteUnicode < ActiveRecord::Migration
  def up
    # We also change imprintable url and asset description to text (otherwise some overflow the new 191 limit)
    change_column :imprintables, :supplier_link, :text
    change_column :assets, :description, :text

    string_columns = {"activities"=>["trackable_type", "owner_type", "key", "recipient_type"], "artwork_requests"=>["priority", "state"], "artworks"=>["name", "description", "local_file_location", "bg_color"], "assets"=>["file_file_name", "file_content_type", "assetable_type", "allowed_content_type"], "brands"=>["name", "sku"], "colors"=>["name", "sku", "hexcode", "map"], "comments"=>["title", "commentable_type", "role"], "coupons"=>["code", "name", "calculator"], "customer_uploads"=>["filename", "url"], "discounts"=>["discountable_type", "discount_method", "transaction_id", "applicator_type"], "email_templates"=>["subject", "from", "bcc", "cc", "template_type", "name", "to"], "emails"=>["subject", "to", "from", "cc", "emailable_type", "bcc"], "freshdesk_local_contacts"=>["name", "email"], "imprint_methods"=>["name"], "imprintable_categories"=>["name"], "imprintable_groups"=>["name"], "imprintables"=>["sizing_category", "material", "main_supplier", "weight", "style_name", "style_catalog_no", "sku", "common_name", "water_resistance_level", "sleeve_type", "sleeve_length", "neck_style", "neck_size", "fabric_type", "fit_type", "fabric_wash", "department_name", "chest_size", "tag", "marketplace_name", "sizing_chart_url"], "imprints"=>["name_format", "number_format"], "in_store_credits"=>["name", "customer_first_name", "customer_last_name", "customer_email"], "ink_colors"=>["name"], "jobs"=>["name", "jobbable_type"], "line_item_groups"=>["name", "description"], "line_item_templates"=>["name", "url"], "line_items"=>["name", "line_itemable_type", "url", "imprintable_object_type"], "name_numbers"=>["name", "number"], "orders"=>["email", "firstname", "lastname", "company", "twitter", "name", "po", "terms", "tax_id_number", "delivery_method", "phone_number", "invoice_state", "production_state", "notification_state", "artwork_state", "customer_key"], "payments"=>["cc_invoice_no", "cc_batch_no", "check_dl_no", "check_phone_no", "pp_transaction_id", "t_name", "t_company_name", "tf_number", "cc_name", "cc_company", "cc_number", "cc_type", "cc_transaction"], "platen_hoops"=>["name"], "print_locations"=>["name"], "proofs"=>["state"], "quote_requests"=>["name", "email", "approx_quantity", "source", "status", "reason", "phone_number", "organization", "freshdesk_ticket_id"], "quotes"=>["email", "phone_number", "first_name", "last_name", "company", "twitter", "name", "quote_source", "freshdesk_ticket_id"], "search_boolean_filters"=>["field"], "search_date_filters"=>["field", "comparator"], "search_filters"=>["filter_holder_type", "filter_type_type"], "search_nil_filters"=>["field"], "search_number_filters"=>["field", "comparator"], "search_phrase_filters"=>["field", "value"], "search_queries"=>["name"], "search_query_fields"=>["name"], "search_query_models"=>["name", "default_fulltext"], "search_reference_filters"=>["field", "value_type"], "search_string_filters"=>["field", "value"], "sessions"=>["session_id"], "settings"=>["name", "val", "encrypted_val"], "shipments"=>["shippable_type", "tracking_number", "status", "name", "company", "attn", "address_1", "address_2", "address_3", "city", "state", "zipcode", "country"], "shipping_methods"=>["name", "tracking_url"], "sizes"=>["name", "display_value", "sku"], "stores"=>["name", "deleted_at", "address_1", "address_2", "city", "state", "zipcode", "country", "phone", "sales_email"], "taggings"=>["taggable_type", "tagger_type", "context"], "tags"=>["name"], "users"=>["email", "encrypted_password", "reset_password_token", "current_sign_in_ip", "last_sign_in_ip", "confirmation_token", "unconfirmed_email", "unlock_token", "first_name", "last_name", "authentication_token", "freshdesk_email", "freshdesk_password", "encrypted_freshdesk_password", "insightly_api_key"], "warning_emails"=>["model", "recipient", "url"], "warnings"=>["warnable_type", "source"]}

    string_columns.each do |table, columns|
      columns.each do |column|
        execute "ALTER TABLE `#{table}` MODIFY `#{column}` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
      end
    end

    all_tables = %w(
      activities artwork_proofs artwork_request_artworks artwork_request_imprints artwork_request_ink_colors
      artwork_request_jobs artwork_requests artworks assets brands colors comments coordinate_imprintables
      coupons customer_uploads discounts email_templates emails freshdesk_local_contacts imprint_method_imprintables
      imprint_method_ink_colors imprint_methods imprintable_categories imprintable_groups imprintable_imprintable_groups
      imprintable_photos imprintable_stores imprintable_variants imprintables imprints in_store_credits ink_colors
      jobs line_item_groups line_item_templates line_items name_numbers order_quotes orders payment_drop_payments
      payment_drops payments platen_hoops print_location_imprintables print_locations proofs quote_request_quotes
      quote_requests quotes sample_locations search_boolean_filters search_date_filters search_filter_groups search_filters
      search_nil_filters search_number_filters search_phrase_filters search_queries search_query_fields search_query_models
      search_reference_filters search_string_filters sessions settings shipments shipping_methods sizes stores
      taggings tags users warning_emails warnings
    )
    all_tables.each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    end
  end

  def down
    change_column :imprintables, :supplier_link, :string
    change_column :assets, :description, :string
    puts "=== WARNING: Can't undo switch to utf8mb4 encoding"
  end
end

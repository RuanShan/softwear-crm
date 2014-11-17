require 'php_serialize'
require 'mysql2'
require 'json'


namespace :quote_requests do

  task import_from_wordpress: :create_db_connection
  task import_old_from_wordpress: :create_db_connection
  task notify_sales_of_bad_quotes: :create_db_connection


  task :create_db_connection do
    @db_client = Mysql2::Client.new(
        host: Figaro.env.wordpress_db_host,
        username: Figaro.env.wordpress_db_username,
        password: Figaro.env.wordpress_db_password,
        database: Figaro.env.wordpress_db_database
    )
  end


  desc 'Connect to worpress db and add pending quotes to database'
  task import_from_wordpress: :environment do

    pending_entries = @db_client.query("select * from wp_rg_lead where is_read is false and date_created > '2014'")
    puts pending_entries.count

    pending_entries.each do |pending_entry|
      begin
        ##############################
        ###### GET LEAD DETAILS ######
        ##############################

        lead_details = @db_client.query("select * from wp_rg_lead_detail where lead_id = #{pending_entry['id']}")
        # need to override the lead field if lead_detail_long exists for it

        lead = {}
        # create lead hash
        lead_details.each do |lead_detail|
          meta_string = @db_client.query("select * from wp_rg_form_meta where form_id = #{pending_entry['form_id']}").first
          meta = JSON.parse(meta_string['display_meta'])
          field = meta['fields'].select{ |field| field['id'].to_i == lead_detail['field_number'].to_i }.first
          lead_detail_long = @db_client.query("select * from wp_rg_lead_detail_long where lead_detail_id = #{lead_detail['id']}").first
          if lead_detail_long
            lead[field['label']] =  lead_detail_long['value']
          else
            lead[field['label']] =  lead_detail['value']
          end
        end
        form_details =  @db_client.query("select * from wp_rg_form where id = #{pending_entry['form_id']}").first

        quantity, date_needed, description, name = nil


        ##############################
        ###### Create AATC Params ####
        ##############################
        lead.each do |key, val|
          if key.downcase.include? 'name'
            name = val
          end

          if key.downcase.include? 'quant'
            quantity = val
          end

          if key.downcase.include? 'needed'
            date_needed = val
          end

          if key.downcase.include? 'mind'
            description = val
          end
        end

        if quantity.nil? || date_needed.nil? || description.nil? || name.nil?
          puts "Quantity or date_needed or description nil for #{lead.inspect}"
          puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
          next
        end


        ##############################
        ######### Send to CRM ########
        ##############################
        quote_request_params = {
            name: name,
            email: lead['Email'],
            approx_quantity: quantity,
            date_needed: Date.parse(date_needed),
            description: description,
            source: form_details['title']
        }

        qr = QuoteRequest.new(quote_request_params)
        if qr.valid?
          query = "update wp_rg_lead set is_read = true where id=#{pending_entry['id']}"
          @db_client.query(query)
          qr.created_at = pending_entry['date_created']
          qr.updated_at = pending_entry['date_created']
          qr.save!
        end


      rescue Exception => e
        puts e.message
        puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
      end
    end
  end


  desc 'Connect to worpress db and add all quotes to database'
  task import_old_from_wordpress: :environment do

    pending_entries = @db_client.query("select * from wp_rg_lead where is_read is true")
    puts pending_entries.count

    pending_entries.each do |pending_entry|
      begin
        ##############################
        ###### GET LEAD DETAILS ######
        ##############################

        lead_details = @db_client.query("select * from wp_rg_lead_detail where lead_id = #{pending_entry['id']}")
        # need to override the lead field if lead_detail_long exists for it

        lead = {}
        # create lead hash
        lead_details.each do |lead_detail|
          meta_string = @db_client.query("select * from wp_rg_form_meta where form_id = #{pending_entry['form_id']}").first
          meta = JSON.parse(meta_string['display_meta'])
          field = meta['fields'].select{ |field| field['id'].to_i == lead_detail['field_number'].to_i }.first
          lead_detail_long = @db_client.query("select * from wp_rg_lead_detail_long where lead_detail_id = #{lead_detail['id']}").first
          if lead_detail_long
            lead[field['label']] =  lead_detail_long['value']
          else
            lead[field['label']] =  lead_detail['value']
          end
        end
        form_details =  @db_client.query("select * from wp_rg_form where id = #{pending_entry['form_id']}").first

        quantity, date_needed, description, name = nil


        ##############################
        ###### Create AATC Params ####
        ##############################
        lead.each do |key, val|
          if key.downcase.include? 'name'
            name = val
          end

          if key.downcase.include? 'quant'
            quantity = val
          end

          if key.downcase.include? 'needed'
            date_needed = val
          end

          if key.downcase.include? 'mind'
            description = val
          end
        end

        if quantity.nil? || date_needed.nil? || description.nil? || name.nil?
          puts "Quantity or date_needed or description nil for #{lead.inspect}"
          puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
          next
        end


        ##############################
        ######### Send to CRM ########
        ##############################
        quote_request_params = {
            name: name,
            email: lead['Email'],
            approx_quantity: quantity,
            date_needed: Date.parse(date_needed),
            description: description,
            source: form_details['title']
        }

        qr = QuoteRequest.new(quote_request_params)
        if qr.valid?
          query = "update wp_rg_lead set is_read = true where id=#{pending_entry['id']}"
          @db_client.query(query)
          qr.created_at = pending_entry['date_created']
          qr.updated_at = pending_entry['date_created']
          qr.status = 'quoted'
          qr.save!
        end


      rescue Exception => e
        puts e.message
        puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
      end
    end
  end

  desc 'Send an e-mail with links to all quotes that didnt import successfully'
  task notify_sales_of_bad_quotes: :environment do
    errors = []
    pending_entries = @db_client.query("select * from wp_rg_lead where is_read is false and date_created > '2014'")
    puts pending_entries.count

    pending_entries.each do |pending_entry|
      begin
        ##############################
        ###### GET LEAD DETAILS ######
        ##############################

        lead_details = @db_client.query("select * from wp_rg_lead_detail where lead_id = #{pending_entry['id']}")
        # need to override the lead field if lead_detail_long exists for it

        lead = {}
        # create lead hash
        lead_details.each do |lead_detail|
          meta_string = @db_client.query("select * from wp_rg_form_meta where form_id = #{pending_entry['form_id']}").first
          meta = JSON.parse(meta_string['display_meta'])
          field = meta['fields'].select{ |field| field['id'].to_i == lead_detail['field_number'].to_i }.first
          lead_detail_long = @db_client.query("select * from wp_rg_lead_detail_long where lead_detail_id = #{lead_detail['id']}").first
          if lead_detail_long
            lead[field['label']] =  lead_detail_long['value']
          else
            lead[field['label']] =  lead_detail['value']
          end
        end
        form_details =  @db_client.query("select * from wp_rg_form where id = #{pending_entry['form_id']}").first

        quantity, date_needed, description, name = nil


        ##############################
        ###### Create AATC Params ####
        ##############################
        lead.each do |key, val|
          if key.downcase.include? 'name'
            name = val
          end

          if key.downcase.include? 'quant'
            quantity = val
          end

          if key.downcase.include? 'needed'
            date_needed = val
          end

          if key.downcase.include? 'mind'
            description = val
          end
        end

        if quantity.nil? || date_needed.nil? || description.nil? || name.nil?
          puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']} Quantity or date_needed or description nil for #{lead.inspect}"
          errors <<  "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']} Quantity or date_needed or description nil for #{lead.inspect}"

          next
        end


        ##################################
        ######### Validate in CRM ########
        ##################################
        quote_request_params = {
            name: name,
            email: lead['Email'],
            approx_quantity: quantity,
            date_needed: Date.parse(date_needed),
            description: description,
            source: form_details['title']
        }

        qr = QuoteRequest.new(quote_request_params)
        if !qr.valid?
          puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
          errors <<  "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
        end


      rescue
        puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
        errors <<  "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{pending_entry['form_id']}&lid=#{pending_entry['id']}"
      end
    end

    QuoteRequestMailer.notify_sales_of_bad_quote_requests(errors).deliver unless errors.empty?

  end

end
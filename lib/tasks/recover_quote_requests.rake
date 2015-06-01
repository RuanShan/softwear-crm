require 'php_serialize'
require 'mysql2'
require 'json'
require 'pp'

namespace :quote_requests do
  task find_missing: :create_db_connection

  task :create_db_connection do
    @db_client = Mysql2::Client.new(
        host: Figaro.env.wordpress_db_host,
        username: Figaro.env.wordpress_db_username,
        password: Figaro.env.wordpress_db_password,
        database: Figaro.env.wordpress_db_database
    )
  end

  desc "Look for quote requests that haven't made it"
  task find_missing: :environment do
    entries = @db_client.query(%[
      select * from wp_rg_lead where date_created > '#{60.days.ago.to_s(:db)}'
    ])

    entries.each do |entry|
      ##############################
      ###### GET LEAD DETAILS ######
      ##############################

      lead_details = @db_client.query("select * from wp_rg_lead_detail where lead_id = #{entry['id']}")
      # need to override the lead field if lead_detail_long exists for it

      lead = {}
      # create lead hash
      lead_details.each do |lead_detail|
        meta_string = @db_client.query("select * from wp_rg_form_meta where form_id = #{entry['form_id']}").first
        meta = JSON.parse(meta_string['display_meta'])
        field = meta['fields'].select{ |field| field['id'].to_i == lead_detail['field_number'].to_i }.first
        lead_detail_long = @db_client.query("select * from wp_rg_lead_detail_long where lead_detail_id = #{lead_detail['id']}").first
        if lead_detail_long
          lead[field['label']] =  lead_detail_long['value']
        else
          lead[field['label']] =  lead_detail['value']
        end
      end
      form_details =  @db_client.query("select * from wp_rg_form where id = #{entry['form_id']}").first



      unless QuoteRequest.where(email: lead['Email']).exists?
        puts "======================================================================"
        puts "Missing quote request with email: #{lead['Email']}"
        puts "---"
        lead.each do |key, value|
          puts "#{key}: #{value}"
        end

        quantity, date_needed, description, name, phone_number, organization = nil


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
            unless val.nil?
              begin
                description = val.gsub!('Δ', '<Delta>').gsub!('Φ', '<Phi>').gsub!('Ε', '<Epsilon>')
              rescue StandardError => e
                if val.blank? && quantity.to_s =~ /\d/
                  description = '(no description provided)'
                else
                  puts "DESCRIPTION VAL: \"#{val}\""
                  description = val if description != val
                end
              end
            end
          end

          if key.downcase.include? 'phone'
            phone_number = val
          end

          if key.downcase.include? 'organization'
            organization = val
          end

          # TODO allow uploading of files
          # if key.downcase.include? 'upload'
          # end
        end

        if quantity.nil? || date_needed.nil? || description.nil? || name.nil?
          puts "[ERROR] Importing http://www.annarbortees.com/wp-admin/admin.php?page=gf_entries&view=entry&id=#{entry['form_id']}&lid=#{entry['id']}"
          puts "quantity = #{quantity}\ndate_needed#{date_needed}\ndescription = #{description}\nname = #{name}\n"
        end


        ##############################
        ######### Send to CRM ########
        ##############################
        quote_request_params = {
            name: name,
            email: lead['Email'],
            approx_quantity: quantity,
            phone_number: phone_number,
            organization: organization,
            date_needed: (Date.parse(date_needed) rescue ''),
            description: description,
            source: form_details['title']
        }

        qr = QuoteRequest.new(quote_request_params)
        bad = false
        if qr.valid?
          query = "update wp_rg_lead set is_read = true where id=#{entry['id']}"
          @db_client.query(query)
          qr.created_at = entry['date_created']
          qr.updated_at = entry['date_created']
          qr.status = 'quoted'
          if qr.save
            puts "Created quote request @ http://crm.softwearcrm.com/quote_requests/#{qr.id}"
          else
            bad = true
          end
        else
          bad = true
        end

        if bad
          puts "ERROR CREATING QUOTE REQUEST: #{qr.errors.full_messages.join(', ')}"
        end

        puts "======================================================================"
      end
    end
  end
end

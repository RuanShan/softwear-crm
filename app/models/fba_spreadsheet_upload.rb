class FbaSpreadsheetUpload < ActiveRecord::Base
  include Softwear::Lib::Enqueue

  validates :spreadsheet, presence: true

  enqueue :create_records
  after_create :enqueue_create_records

  def spreadsheet=(value)
    @spreadsheet_hash = nil
    if value.respond_to?(:path)
      self.filename = File.basename(value.try(:original_filename) || value.path)
      super(SimpleXlsxReader.open(value.path).to_hash.to_json)
    else
      self.filename = File.basename(value)
      super(SimpleXlsxReader.open(value).to_hash.to_json)
    end
  end

  def spreadsheet
    return @spreadsheet_hash if @spreadsheet_hash
    text = super
    @spreadsheet_hash = JSON.parse(text) unless text.blank?
  end

  def create_records
    row_ident = -> (i) { i + 1 }

    # sheetname => rownumber => errormessage
    all_errors = {}
    created_job_templates = []

    spreadsheet.each do |sheet_name, rows|
      if /IGNORE/ =~ sheet_name
        # Not really an error but this lets them know that it wasn't touched
        all_errors[sheet_name] = { 1 => %(Name contains "IGNORE" - skipped) }
        next
      end

      header = {}
      errors = {}
      action = nil
      first_row_of_current_product = -1
      current_product = nil
      current_fba_skus = nil

      report_error = lambda do |row, message|
        next false unless message && message.is_a?(String)

        errors[row_ident[row]] = message
        true
      end

      complete_product = lambda do |row|
        current_product.fba_skus_attributes = current_fba_skus

        unless current_product.save
          report_error.call(row, current_product.errors.full_messages.join(', '))
        end

        current_product = nil
      end

      add_fba_sku = lambda do |row|
        sku   = row[header[:msku]]
        fnsku = row[header[:fnsku]]
        asin  = row[header[:asin]]

        next false if sku.blank?

        brand_name            = row[header[:brand]]
        style_catalog_no      = row[header[:style]]
        color_name            = row[header[:color]]
        size_display_value    = row[header[:size]]
        fba_job_template_name = row[header[:template]]
        variant_attributes = [
          brand_name, style_catalog_no, color_name,
          size_display_value, fba_job_template_name
        ]

        # Skip entirely empty lines
        next false if variant_attributes.all?(&:blank?)
        # Report error on partially empty lines
        next "Incomplete imprintable variant info" if variant_attributes.any?(&:blank?)

        brand = Brand.find_by name: brand_name

        next "No brand called \"#{brand_name}\" was found" if brand.nil?

        imprintable_variant = ImprintableVariant
          .joins(:imprintable)
          .where(imprintables: { brand_id: brand.id, style_catalog_no: style_catalog_no })
          .joins(:color)
          .where(colors: { name: color_name })
          .joins(:size)
          .where(sizes: { display_value: size_display_value })
          .first

        if imprintable_variant.nil?
          next "No matching imprintable variant found: " \
            "#{brand_name} #{style_catalog_no} - #{color_name}, #{size_display_value}"
        end

        fba_job_template = FbaJobTemplate.find_by name: fba_job_template_name

        next "No matching job template found" if fba_job_template.nil?

        fba_sku_attributes = {
          sku:   sku,
          fnsku: fnsku,
          asin:  asin,

          imprintable_variant_id: imprintable_variant.id,
          fba_job_template_id:    fba_job_template.id
        }

        if fba_sku = FbaSku.find_by(sku: sku)
          if fba_sku.fba_product.nil?
            fba_sku.destroy
          elsif !current_product.persisted? || fba_sku.fba_product.id != current_product.id
            next "The child sku #{sku} already belongs to FBA Product #{fba_sku.fba_product.name}"
          end

          fba_sku_attributes[:id] = fba_sku.id if fba_sku.persisted?
        end

        current_fba_skus << fba_sku_attributes

        true
      end

      read_fba_product = lambda do |row, rownum|
        if row[header[:name]].blank?
          next if current_product.nil?
          report_error.call rownum, add_fba_sku.call(row)
        else
          unless current_product.nil?
            complete_product.call first_row_of_current_product
          end

          first_row_of_current_product = rownum
          current_product = FbaProduct.find_or_initialize_by(
            name: row[header[:name]],
            sku:  row[header[:parent_sku]]
          )
          current_fba_skus = []

          report_error.call rownum, add_fba_sku.call(row)
        end
      end

      read_fba_job_template = lambda do |row, rownum|
        next if row.all?(&:blank?)

        fba_job_template = FbaJobTemplate.find_or_initialize_by name: row[header[:name]]
        fba_job_template.job_name = row[header[:job_name]]
        unless fba_job_template.save
          report_error.call rownum, "Couldn't update job template info: #{fba_job_template.errors.full_messages.join(', ')}"
          next
        end

        imprint_method_name = row[header[:imprint_method]]
        if imprint_method_name.blank?
          report_error.call rownum, "No imprint method supplied" and next
        end
        imprint_method = ImprintMethod.find_by name: imprint_method_name
        if imprint_method.nil?
          report_error.call rownum, "Couldn't find imprint method called \"#{imprint_method_name}\""
          next
        end

        print_location_name = row[header[:print_location]]
        if print_location_name.blank?
          report_error.call rownum, "No print location supplied" and next
        end
        print_location = imprint_method.print_locations.find_by name: print_location_name
        if print_location.blank?
          report_error.call rownum, "Couldn't find print location for #{imprint_method_name}: \"#{print_location_name}\""
          next
        end

        description = row[header[:description]]

        imprint = fba_job_template.fba_imprint_templates.find_or_initialize_by(print_location_id: print_location.id)
        imprint.description = description
        if imprint.save
          created_job_templates << fba_job_template
        else
          report_error.call rownum, "Couldn't save imprint: #{imprint.errors.full_messages.join(', ')}"
          next
        end
      end

      find_header = proc do |row|
        row.each_with_index do |cell, index|
          case cell.try(:downcase)
          when nil then next
          when "name"                  then header[:name]           = index
          when /(master|parent)\s+sku/ then header[:parent_sku]     = index
          when "msku"                  then header[:msku]           = index
          when "fnsku"                 then header[:fnsku]          = index
          when "asin"                  then header[:asin]           = index
          when "brand"                 then header[:brand]          = index
          when "style"                 then header[:style]          = index
          when "color"                 then header[:color]          = index
          when "size"                  then header[:size]           = index
          when /job\s+template/        then header[:template]       = index
          when /job\s+name/            then header[:job_name]       = index
          when /imprint\s+method/      then header[:imprint_method] = index
          when /print\s+location/      then header[:print_location] = index
          when "description"           then header[:description]    = index
          end
        end

        unless header.values.any?(&:blank?)
          if %i(name parent_sku fnsku asin brand style color size template) - header.keys == []
            action = read_fba_product
          elsif %i(name job_name imprint_method print_location description) - header.keys == []
            action = read_fba_job_template
          end
        end
      end

      action = find_header

      rows.each_with_index do |row, index|
        action.call(row, index)
      end
      if action == find_header
        errors[0] = "Couldn't find header"
      elsif !current_product.nil?
        complete_product.call first_row_of_current_product
      end
      all_errors[sheet_name] = errors unless errors.empty?
    end

    Sunspot.index! created_job_templates unless created_job_templates.empty?

    errors_string = ""
    all_errors.each do |sheet, sheet_errors|
      errors_string += "=== Sheet: \"#{sheet}\" ===\n"
      sheet_errors.each do |row_number, message|
        errors_string += "Row #{row_number}: #{message}\n"
      end
      errors_string += "\n"
    end

    self.processing_errors = errors_string
    self.done = true
    save!

    all_errors
  end
end

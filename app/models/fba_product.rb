class FbaProduct < ActiveRecord::Base
  has_many :fba_skus, dependent: :destroy

  accepts_nested_attributes_for :fba_skus, allow_destroy: true

  validates :name, presence: true, uniqueness: true
  validates :sku, presence: true

  searchable do
    text :name, :sku, :fba_sku_skus
  end

  def fba_sku_skus
    fba_skus.pluck(:sku)
  end

  def self.create_from_spreadsheet(filename)
    doc = SimpleXlsxReader.open(filename)
    row_ident = -> (i) { i + 1 }

    # sheetname => rownumber => errormessage
    all_errors = {}

    doc.sheets.each do |sheet|
      next if /IGNORE/ =~ sheet.name

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

        next "No matching imprintable variant found" if imprintable_variant.nil?

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
          if current_product.persisted? && fba_sku.fba_product.id != current_product.id
            next "The child sku #{sku} already belongs to FBA Product #{fba_sku.fba_product.name}"
          end

          fba_sku_attributes[:id] = fba_sku.id
        end

        current_fba_skus << fba_sku_attributes

        true
      end

      read = lambda do |row, rownum|
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

      find_header = proc do |row|
        row.each_with_index do |cell, index|
          case cell.try(:downcase)
          when nil then next
          when "name"                  then header[:name]       = index
          when /(master|parent)\s+sku/ then header[:parent_sku] = index
          when "msku"                  then header[:msku]       = index
          when "fnsku"                 then header[:fnsku]      = index
          when "asin"                  then header[:asin]       = index
          when "brand"                 then header[:brand]      = index
          when "style"                 then header[:style]      = index
          when "color"                 then header[:color]      = index
          when "size"                  then header[:size]       = index
          when /job\s+template/        then header[:template]   = index
          end
        end

        if %i(name parent_sku fnsku asin brand style color size template) - header.keys == [] &&
           !header.values.any?(&:blank?)
          action = read
        end
      end

      action = find_header

      sheet.rows.each_with_index do |row, index|
        action.call(row, index)
      end
      if action == find_header
        errors[0] = "Couldn't find header"
      elsif !current_product.nil?
        complete_product.call first_row_of_current_product
      end
      all_errors[sheet.name] = errors unless errors.empty?
    end

    all_errors
  end
end

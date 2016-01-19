class FBA
  SKU = Struct.new(:version, :idea, :print, :imprintable, :size, :color)
  module PendingLineItems
    def line_items_attributes
      hash = {}
      each_with_index do |e, index|
        hash[index] = {
          quantity:          e.quantity,
          unit_price:        0,
          imprintable_price: 0,
          decoration_price:  0,
          imprintable_object_type: 'ImprintableVariant',
          imprintable_object_id:    e.fba_sku.imprintable_variant_id
        }
      end
      hash
    end
  end

  class << self
    # Possible keys:
    # { :fatal_error => message }     if the file could not be parsed  (check for this first)
    # { :errors => list_of_messages } if there were some other problems
    # { :jobs_attributes => jobs_attributes } these attributes will be valid form input
    def parse_packing_slip(packing_slip, options = {})
      options[:filename] ||= '<unknown file>'
      routes = options[:context]

      header, data = parse_file(packing_slip)
      result = {
        errors: [],
        jobs_attributes: {},
        filename: options[:filename]
      }

      if header.blank? || data.blank?
        return { fatal_error: "Couldn't parse #{options[:filename]}" }
      end

      # Pass 1: Just collect (and report bad skus)
      job_groups = {}
      data.each do |datum|
        sku     = datum['Merchant SKU']
        fba_sku = FbaSku.find_by(sku: sku)

        if fba_sku.nil?
          result[:errors] << lambda do |view|
            "No FBA Product was found with a child sku of #{sku}. Configure FBA Products "\
            "#{view.link_to 'here', view.fba_products_path, target: :_blank}."
          end
          next
        end
        fba_product      = fba_sku.fba_product
        fba_job_template = fba_sku.fba_job_template

        if fba_product.nil?
          # This really shouldn't happen - FbaSku can only be created through the FbaProduct form
          fba_sku.destroy
          result[:errors] << lambda do |view|
            "There was a bug in the entry for sku #{sku}. It will have to be re-added "\
            "from the #{view.link_to 'FBA Products', view.fba_products_path, target: :_blank} page."
          end
          next
        elsif fba_job_template.nil?
          result[:errors] << lambda do |view|
            "The entry for sku #{sku} does not have a job template. You can set one "\
            "#{view.link_to 'here', view.edit_fba_product_path(fba_product), target: :_blank} and then "\
            "re-upload the packing slip."
          end
          next
        end

        # The extend thing is only so that I can say "skus.line_items_attributes" in the next pass
        job_groups[[fba_product, fba_job_template]] ||= [].tap { |a| a.send :extend, PendingLineItems }
        job_groups[[fba_product, fba_job_template]] << OpenStruct.new(fba_sku: fba_sku, quantity: datum['Shipped'])
      end

      # Pass 2: Add job attributes
      job_groups.each do |key, skus|
        fba_product, fba_job_template = key

        result[:jobs_attributes][key.hash] = {
          name:        "#{fba_product.name} #{fba_job_template.name} - #{header['Shipment ID']}",
          description: "Generated from packing slip #{options[:filename]} and FBA Product ##{fba_product.id}, "\
                       "Job Template ##{fba_job_template.id}",
          line_items_attributes: skus.line_items_attributes,
          imprints_attributes:   fba_job_template.imprints_attributes,
          collapsed: true
        }
      end

      result
    end

    def old_parse_packing_slip(packing_slip, options = {})
      header, data = parse_file(packing_slip)

      errors = []
      jobs = {}
      all_imprintables = {}

      if header.blank? || data.blank?
        errors << "Could not parse file"
        return FBA.new(
          "Bad file #{options[:filename] || Random.rand}",
          {},
          errors,
          options[:filename]
        )
      end

      data.each do |datum|
        sku = parse_sku(datum)
        if sku.nil?
          errors << "SKU #{datum['Merchant SKU']} could not be parsed"
          next
        end

        unless imprintable = all_imprintables[sku.imprintable]
          imprintable = imprintable_entry(sku, errors) or next

          all_imprintables[sku.imprintable] = imprintable

          if imprintable[:isolate]
            jobs[imprintable[:imprintable].style_name] ||= {}
            jobs[imprintable[:imprintable].style_name][sku.imprintable] = imprintable
          else
            jobs['main'] ||= {}
            jobs['main'][sku.imprintable] = imprintable
          end
        end

        unless color = imprintable[:colors][sku.color]
          color = color_entry(sku, errors) or next
          imprintable[:colors][sku.color] = color
        end

        size = size_entry(sku, datum, imprintable, errors) or next
        color[:sizes][sku.size] = size
      end

      FBA.new(
        "Shipment #{header['Shipment ID']}",
        form_data(jobs),
        errors,
        options[:filename]
      )
    end

    def imprintable_entry(sku, errors)
      record = Imprintable.find_by(sku: sku.imprintable)

      if record.nil?
        errors << "No imprintable with SKU #{sku.imprintable} was found"
        return nil
      end

      {
        imprintable: record,
        colors: {},
        isolate: /infant|toddler|onesie/i =~ record.style_name.to_s
      }
    end

    def color_entry(sku, errors)
      record = Color.find_by(sku: sku.color)

      if record.nil?
        errors << "No color with SKU #{sku.color} was found"
        return nil
      end

      {
        color: record,
        sizes: {}
      }
    end

    def size_entry(sku, data, imprintable_hash, errors)
      record = Size.find_by(sku: sku.size)

      if record.nil?
        errors << "No size with SKU #{sku.size} was found"
        return nil
      end

      imprintable = imprintable_hash[:imprintable]
      color = imprintable_hash[:colors][sku.color][:color]

      variant = ImprintableVariant.where(
        imprintable_id: imprintable.id,
        color_id:       color.id,
        size_id:        record.id
      )

      unless variant.exists?
        errors << "The imprintable #{imprintable.name} (SKU #{imprintable.sku}) does not have a variant of "\
                  "color: #{color.name} (SKU #{color.sku}), size: #{record.name} (SKU #{record.sku})"
        return nil
      end

      {
        size: record,
        quantity: data['Shipped']
      }
    end

    def form_data(jobs)
      data = {}

      # Transform imprintable data into a json friendly format.
      # This format is assumed by Order#generate_jobs.
      jobs.each do |style, imprintables|
        imprintables.each do |_, imprintable|
          imprintable[:colors].each do |_, color|
            quantities = {}
            color[:sizes].each do |_, size|
              quantities[size[:size].id] = size[:quantity]
            end

            data[style] ||= []
            data[style] << [
              imprintable[:imprintable].id,
              color[:color].id,
              quantities
            ]
          end
        end
      end

      data
    end

    def parse_sku(data)
      sku = data.is_a?(Hash) ? data['Merchant SKU'] : data

      version = sku.try(:[], 0)
      case version
      when '0'
        /\d\-(?<idea>\w+)\-
        (?<print>\d)
        (?<imprintable>\d{4})
        (?<size>\d{2})
        (?<color>\d{3})/x =~ sku

      else return nil
      end

      SKU.new(version, idea, print, imprintable, size, color)
    end

    def parse_file(file)
      return parse_header(file), parse_footer(file)
    end

    def parse_header(file)
      data = {}

      file.each_line do |line|
        break if line.whitespace?
        key_value = line.split("\t").map(&:strip)
        data[key_value.first] = key_value.last
      end

      data
    end

    def parse_footer(file)
      data = []

      first_line = file.gets
      return nil if first_line.nil?

      keys = first_line.split("\t").map(&:strip)

      file.each_line do |line|
        row = {}

        line.split("\t").map(&:strip).each_with_index do |value, i|
          row[keys[i]] = value
        end

        data << row
      end

      data
    end
  end

  attr_reader :jobs
  attr_reader :errors
  attr_reader :job_name
  attr_reader :filename

  def initialize(job_name, jobs, errors = [], filename = nil)
    @job_name = job_name
    @errors   = errors
    @jobs     = jobs
    @filename = filename
  end

  def errors?
    !@errors.empty?
  end

  def to_h
    {
      job_name: job_name,
      filename: filename,
      jobs:     jobs
    }
  end
end

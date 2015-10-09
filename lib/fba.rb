class FBA
  SKU = Struct.new(:version, :idea, :print, :imprintable, :size, :color)

  class << self
    def parse_packing_slip(packing_slip, options = {})
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

class FBA
  SKU = Struct.new(:version, :idea, :print, :imprintable, :size, :color)

  class << self
    def parse_packing_slip(packing_slip, options = {})
      header, data = parse_file(packing_slip)

      errors = []
      imprintables = {}

      data.each do |datum|
        sku = parse_sku(datum)
        if sku.nil?
          errors << "SKU #{datum['Merchant SKU']} could not be parsed"
          next
        end

        unless imprintable = imprintables[sku.imprintable]
          imprintable = imprintable_entry(sku, errors) or next
          imprintables[sku.imprintable] = imprintable
        end

        unless color = imprintable[:colors][sku.color]
          color = color_entry(sku, errors) or next
          imprintable[:colors][sku.color] = color
        end

        size = size_entry(sku, datum, errors) or next
        color[:sizes][sku.size] = size
      end

      FBA.new("Shipment #{header['Shipment ID']}", form_data(imprintables), errors, options[:filename])
    end

    def imprintable_entry(sku, errors)
      record = Imprintable.find_by(sku: sku.imprintable)

      if record.nil?
        errors << "No imprintable with SKU #{sku.imprintable} was found"
        return nil
      end

      {
        imprintable: record,
        colors: {}
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

    def size_entry(sku, data, errors)
      record = Size.find_by(sku: sku.size)

      if record.nil?
        errors << "No size with SKU #{sku.size} was found"
        return nil
      end

      {
        size: record,
        quantity: data['Shipped']
      }
    end

    def form_data(imprintables)
      data = []

      # Transform imprintable data into a json friendly format.
      # This format is assumed by Order#generate_jobs.
      imprintables.each do |_, imprintable|
        imprintable[:colors].each do |_, color|
          quantities = {}
          color[:sizes].each do |_, size|
            quantities[size[:size].id] = size[:quantity]
          end

          data << [
            imprintable[:imprintable].id,
            color[:color].id,
            quantities
          ]
        end
      end

      data
    end

    # TODO unused
    def retrieve_colors(data, options = {})
      sizes_by_color = {}

      data.each do |row|
        sku = parse_sku(row)

        color = sizes_by_color[sku.color] ||= color_from(sku, options)
        color.sizes << size_from(sku, row, color, options)
      end

      return sizes_by_color.values
    end

    def option?(options, *keys)
      yield keys.reduce(options) { |current, key| current.try(:[], key) ||
                                                  current.try(:[], key.to_s) }
    end

    # TODO unused
    def color_from(sku, options = {})
      color = option?(options, :colors, sku.color) do |color_id|
        color_id ? ::Color.find(color_id) : ::Color.find_by(sku: sku.color)
      end

      FBA::Color.new(color, [], color.try(:sku) || sku.color)
    end

    # TODO unused
    def size_from(sku, data, color, options = {})
      size = option?(options, :sizes, sku.size) do |size_id|
        size_id ? ::Size.find(size_id) : ::Size.find_by(sku: sku.size)
      end

      FBA::Size.new(
        size,
        data['Shipped'],
        size.try(:sku) || sku.size,
        color.try(:sku) || sku.color
      )
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

  attr_reader :imprintables
  attr_reader :errors
  attr_reader :job_name
  attr_reader :filename

  def initialize(job_name, imprintables, errors, filename)
    @job_name     = job_name
    @errors       = errors
    @imprintables = imprintables
    @filename     = filename
  end

  def errors?
    !@errors.empty?
  end

  def to_h
    {
      job_name:     job_name,
      filename:     filename,
      imprintables: imprintables
    }
  end
end

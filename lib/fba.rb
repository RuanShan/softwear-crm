class FBA
  Color = Struct.new(:color, :sizes, :sku) do
    def to_h
      return nil unless color
      {
        color: color.id,
        sizes: sizes.compact.map(&:to_h)
      }
    end
  end
  Size = Struct.new(:size, :quantity, :sku, :color_sku) do
    def to_h
      return nil unless size
      {
        size: size.id,
        quantity: quantity.to_i
      }
    end
  end
  SKU = Struct.new(:version, :idea, :print, :imprintable, :size, :color)
  Error = Struct.new(:message, :item, :type)

  class << self
    def parse_packing_slip(packing_slip, options = {})
      header, data = parse_file(packing_slip)
      sku = parse_sku(data.first)

      if sku.nil?
        return FBA.new(
            errors: [
              Error.new(
                'Bad sku or invalid packing slip',
                data.first['Merchant ID'], :bad_sku
              )
            ]
          )
      end

      imprintable_sku = nil

      imprintable = option?(options, :imprintables, sku.imprintable) do |imp_sku|
        imprintable_sku = imp_sku ? imp_sku : sku.imprintable
        Imprintable.find_by(sku: imprintable_sku)
      end

      colors = retrieve_colors(data, options)

      FBA.new(
        job_name: "#{sku.idea} #{header['Shipment ID']}",
        colors: colors,
        imprintable: imprintable,
        imprintable_sku: imprintable_sku
      )
    end

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

    def color_from(sku, options = {})
      color = option?(options, :colors, sku.color) do |color_id|
        color_id ? ::Color.find(color_id) : ::Color.find_by(sku: sku.color)
      end

      FBA::Color.new(color, [], color.try(:sku) || sku.color)
    end

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

  attr_reader :job_name
  attr_reader :colors
  attr_reader :imprintable

  def initialize(options = {})
    @job_name        = options[:job_name]
    @colors          = options[:colors]
    @imprintable     = options[:imprintable]
    @imprintable_sku = options[:imprintable_sku]
    
    @errors = options[:errors] if options[:errors]
  end

  def to_h
    if imprintable.nil?
      {
        job_name: @job_name
      }
    else
      {
        job_name: @job_name,
        imprintable: @imprintable.id,
        colors: @colors.map(&:to_h).compact
      }
    end
  end

  def errors
    @errors ||= find_errors
  end

  private

  def find_errors
    check = proc do |for_func|
      result = send("check_#{for_func}")
      return result unless result.nil? || result.empty?
    end

    %w(
      for_nil_imprintable
      for_nil_colors
      for_nil_sizes
      for_invalid_sizes
    )
      .each(&check)

    []
  end

  def check_for_nil_imprintable
    if imprintable.nil?
      [
        Error.new(
          "Couldn't find imprintable with sku '#{@imprintable_sku}'",
          @imprintable_sku,
          :nil_imprintable
        )
      ]
    end
  end

  def check_for_nil_colors
    colors
      .select { |c| c.color.nil? }
      .map { |c| Error.new("Couldn't find color with sku '#{c.sku}'", c, 
                           :nil_color) }
  end

  def check_for_nil_sizes
    checked = {}
    
    colors.flat_map do |fba_color|
      fba_color.sizes.map do |fba_size|
        next if checked[fba_size.sku]

        if fba_size.size.nil?
          Error.new(
            "Couldn't find size with sku '#{fba_size.sku}'",
            fba_size,
            :nil_size
          )
        end
      end
        .compact
    end
  end

  def check_for_invalid_sizes
    [].tap do |errors|
      
      colors.each do |fba_color|
        valid_size_variants =
          ImprintableVariant.size_variants_for(imprintable, fba_color.color)

        bad_sizes = fba_color.sizes.select do |fba_size|
          unless valid_size_variants.any? { |v| v.size_id == fba_size.size.id }
            errors << Error.new(
                "Size with sku '#{fba_size.size.sku}' is not valid "\
                "(No imprintable variant found) for "\
                "the imprintable #{imprintable.common_name} and color "\
                "#{fba_color.color.name}",
                fba_size,
                :invalid_size
              )
          end
        end

        fba_color.sizes -= bad_sizes
      end

    end
  end
end

class FBA
  Color = Struct.new(:color, :sizes, :sku) do
    def to_h
      {
        color: color.id,
        sizes: sizes.map(&:to_h)
      }
    end
  end
  Size = Struct.new(:size, :quantity, :sku, :color_sku) do
    def to_h
      {
        size: size.id,
        quantity: quantity.to_i
      }
    end
  end
  SKU = Struct.new(:version, :idea, :print, :imprintable, :size, :color)
  Error = Struct.new(:message, :item)

  class << self
    def parse_packing_slip(packing_slip, options = {})
      header, data = parse_file(packing_slip)
      sku = parse_sku(data.first)

      if sku.nil?
        return FBA.new(errors: [Error.new('Bad sku', data['Merchant ID'])])
      end

      colors = retrieve_colors(data)

      FBA.new(
        job_name: "#{sku.idea} #{header['Shipment ID']}",
        colors: colors,
        imprintable: Imprintable.find_by(sku: sku.imprintable),
        imprintable_sku: sku.imprintable
      )
    end

    def retrieve_colors(data)
      sizes_by_color = {}

      data.each do |row|
        sku = parse_sku(row)

        sizes_by_color[sku.color] ||= color_from(sku)
        sizes_by_color[sku.color].sizes << size_from(sku, row)
      end

      return sizes_by_color.values
    end

    def color_from(sku)
      FBA::Color.new(
        ::Color.find_by(sku: sku.color),
        [],
        sku.color
      )
    end

    def size_from(sku, data)
      FBA::Size.new(
        ::Size.find_by(sku: sku.size),
        data['Shipped'],
        sku.size,
        sku.color
      )
    end

    def parse_sku(data)
      sku = data.is_a?(Hash) ? data['Merchant SKU'] : data

      version = sku[0]
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

      keys = file.gets.split("\t").map(&:strip)
      
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
    {
      job_name: @job_name,
      imprintable: @imprintable.id,
      colors: @colors.map(&:to_h)
    }
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
          @imprintable_sku
        )
      ]
    end
  end

  def check_for_nil_colors
    colors
      .select { |c| c.color.nil? }
      .map { |c| Error.new("Couldn't find color with sku '#{c.sku}'", c) }
  end

  def check_for_nil_sizes
    checked = {}
    
    colors.flat_map do |fba_color|
      fba_color.sizes.map do |fba_size|
        next if checked[fba_size.sku]

        if fba_size.size.nil?
          Error.new(
            "Couldn't find size with sku '#{fba_size.sku}'",
            fba_size
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
                "Size with sku '#{fba_size.size.sku}' is not valid for "\
                "the imprintable #{imprintable.common_name} and color "\
                "#{fba_color.color.name}",
                fba_size
              )
          end
        end

        fba_color.sizes -= bad_sizes
      end

    end
  end
end

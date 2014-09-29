class FBA
  Color = Struct.new(:color, :sizes)
  Size = Struct.new(:size, :quantity)
  SKU = Struct.new(:version, :idea, :print, :imprintable, :size, :color)

  def self.parse_packing_slip(packing_slip, options = {})
    props = {}

    header, data = parse_file(packing_slip)

    imprintable_sku = parse_sku(data.first).imprintable
    byebug
  end

  attr_reader :errors
  attr_reader :job_name
  attr_reader :colors
  attr_reader 

  def initialize(options = {})
    @job_name    = options[:job_name]
    @colors      = options[:colors]
    @imprintable = options[:imprintable]
  end

  private

  def self.parse_sku(data)
    sku = data.is_a?(Hash) ? data['Merchant SKU'] : data

    version = sku[0]
    case version
    when 0
      /\d\-(?<idea>\w+)\-
      (?<print>\d)
      (?<imprintable>\d{4})
      (?<size>\d{2})
      (?<color>\d{3})/x =~ sku
      byebug
    end

    SKU.new(version, idea, print, imprintable, size, color)
  end

  def self.parse_file(file)
    return parse_header(file), parse_footer(file)
  end

  def self.parse_header(file)
    data = {}

    file.each_line do |line|
      break if line.whitespace?
      key_value = line.split("\t").map(&:strip)
      data[key_value.first] = key_value.last
    end

    data
  end

  def self.parse_footer(file)
    data = []

    keys = file.gets.split("\t").map(&:strip)
    
    file.each_line do |line|
      datum = {}

      line.split("\t").map(&:strip).each_with_index do |value, i|
        datum[keys[i]] = value
      end

      data << datum
    end

    data
  end
end

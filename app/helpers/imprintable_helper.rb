module ImprintableHelper
  def find_brand(imprintable)
    if imprintable.style_id.present?
      brand = imprintable.style.brand
      brand.id
    else
      nil
    end
  end

  def table_entries(table)
    string = String.new
    table.each do |entry|
      string += ', ' + entry.name.to_s
    end
    string.sub!(/, /, '')
  end

  def display_sizes(imprintable)
    if imprintable.sizes.first.nil?
      return 'There are no sizes available'.html_safe
    elsif imprintable.sizes.first == imprintable.sizes.last
      return imprintable.sizes.first.display_value
    else
      return "#{imprintable.sizes.first.display_value} - #{imprintable.sizes.last.display_value}"
    end
  end
end
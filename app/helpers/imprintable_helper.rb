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
end
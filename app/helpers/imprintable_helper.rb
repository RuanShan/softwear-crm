module ImprintableHelper
  def table_entries(table)
    table.to_a.map(&:name).join(', ')
  end

  def display_sizes(imprintable)
    if imprintable.sizes.first.nil?
      'There are no sizes available'.html_safe
    elsif imprintable.sizes.size == 1
      return imprintable.sizes.first.display_value
    else
      "#{imprintable.sizes.first.display_value} - #{imprintable.sizes.last.display_value}"
    end
  end

  def pricing_table_data_for(pricing_hash)
    data = content_tag(:td, link_to(pricing_hash[:name], pricing_hash[:supplier_link]))
    data += content_tag(:td, pricing_hash[:quantity])
    data += content_tag(:td, pricing_hash[:sizes])

    pricing_hash[:prices].each do |price, value|
      if value == 'n/a'
        data += content_tag(:td, 'n/a')
      else
        data += content_tag(:td, number_to_currency(value))
      end
    end

    data
  end

  def omit_unused_prices_from(pricing_groups)
    # new_pricing_array = pricing_array.map(&:deep_dup)
    new_pricing_groups = {}
    pricing_groups.each do |k, v|
      new_pricing_groups[k] = v.map(&:deep_dup)
    end
    all_pricing_hashes = new_pricing_groups.values.flatten

    [
      :xxxxxxl_price,
      :xxxxxl_price,
      :xxxxl_price,
      :xxxl_price,
      :xxl_price,
      :xl_price
    ]
      .map do |price|
        OpenStruct.new(
          price: price,
          # prices: new_pricing_array.map do |pricing_hash|
              # pricing_hash[:prices][price]
            # end
          prices: all_pricing_hashes.map do |pricing_hash|
            pricing_hash[:prices][price]
          end
        )
      end
      .each do |data|
        if data.prices.all? { |p| p == 'n/a' }
          all_pricing_hashes.each do |pricing_hash|
            pricing_hash[:prices].delete(data.price)
            pricing_hash[:prices].delete(data.price.to_s)
          end
        else
          return new_pricing_groups
        end
      end

    # new_pricing_array
    new_pricing_groups
  end
end

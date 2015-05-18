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
end

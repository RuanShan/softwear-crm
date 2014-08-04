module ImprintableHelper
  def table_entries(table)
    string = String.new

    # TODO: use join
    table.each do |entry|
      string += ', ' + entry.name.to_s
    end

    string.sub!(/, /, '')
  end

  def display_sizes(imprintable)
    if imprintable.sizes.first.nil?
      'There are no sizes available'.html_safe
    elsif imprintable.sizes.first == imprintable.sizes.last
      # TODO: is this return necessary?
      return imprintable.sizes.first.display_value
    else
      "#{imprintable.sizes.first.display_value} - #{imprintable.sizes.last.display_value}"
    end
  end
end

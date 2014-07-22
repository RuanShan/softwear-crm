module LineItemHelper
  def line_item_id(line_item)
    sub = -> (s) { s.gsub(/[^a-zA-Z\d]/, '-') }
    if line_item.is_a? String
      sub.call(line_item)
    else
      sub.call(line_item.name)
    end
  end

  def determine_url(line_item, line_itemable)
    if line_itemable.is_a? Job
      return job_line_items_path(line_itemable, line_item)
    elsif line_itemable.is_a? Quote
      return quote_line_items_path(line_itemable, line_item)
    end
  end
end

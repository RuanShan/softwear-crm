module LineItemHelper
  def line_item_id(line_item)
    sub = -> (s) { s.gsub(/[^a-zA-Z\d]/, '-') }
    
    "line-itemable-#{line_item.line_itemable.id}-line-item-#{line_item.id}" rescue (
      line_item.is_a?(String) ? sub.call(line_item) : sub.call(line_item.name)
    )
  end

  # TODO: test if return is necessary
  def determine_url(line_item, line_itemable)
    if line_itemable.is_a? Job
      job_line_items_path(line_itemable, line_item)
    elsif line_itemable.is_a? Quote
      return quote_line_items_path(line_itemable, line_item)
    end
  end
end

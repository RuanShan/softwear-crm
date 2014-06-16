module LineItemHelper
  def line_item_id(line_item)
    sub = -> (s) { s.gsub(/[^a-zA-Z\d]/, '-') }
    if line_item.is_a? String
      sub.call(line_item)
    else
      sub.call(line_item.name)
    end
  end
end
class QuoteDrop < Liquid::Drop

  def initialize(quote)
    @quote = quote
  end

  def id
    @quote["id"]
  end

  def name
    @quote["name"]
  end

  def customer_full_name
    @quote.full_name
  end

  def line_item_groups
    @quote.line_item_groups.map{ |lig| LineItemGroupDrop.new(lig) }
  end

end


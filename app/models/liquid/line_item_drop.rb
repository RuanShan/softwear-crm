class LineItemDrop < Liquid::Drop

  def initialize(line_item)
    @line_item = line_item
  end

  def id
    @line_item.id
  end

  def name
    @line_item.name
  end

  def quantity
    @line_item.quantity
  end

  def taxable
    @line_item.taxable
  end

  def description
    @line_item.description
  end

  def unit_price
    @line_item.unit_price
  end

  def url
    @line_item.url
  end

end


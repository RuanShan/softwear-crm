class LineItemGroupDrop < Liquid::Drop

  def initialize(line_item_group)
    @line_item_group = line_item_group
  end

  def name
    @line_item_group.name
  end

  def description
    @line_item_group.description
  end

  def line_items
    @line_item_group.line_items.map{|li| LineItemDrop.new(li)}
  end

end


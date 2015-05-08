class ImprintableTierDrop < Liquid::Drop

  def initialize(params)
    @imprintable_tier = params
  end

  def name
    @imprintable_tier[:name]
  end

  def line_items
    @imprintable_tier[:job].imprintable_line_items_for_tier(@imprintable_tier[:number]).map{|li| LineItemDrop.new(li)}
  end

end


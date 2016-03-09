class CostsController < InheritedResources::Base
  def mass_new
    @before = Time.now
    @line_items_by_imprintable = LineItem.in_need_of_cost(1000)
    @after = Time.now
  end

  def mass_create
  end
end

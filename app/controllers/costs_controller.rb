class CostsController < InheritedResources::Base
  def mass_new
    @line_items_by_imprintable = LineItem.in_need_of_cost(1000)
  end

  def mass_create
    # TODO
    # Queue up a sidekiq job and/or build up a huge SQL query
  end
end

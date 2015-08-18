class AddSortOrderToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :sort_order, :integer
  end
end

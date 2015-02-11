class AddDefaultValueToLineItemsTaxable < ActiveRecord::Migration
  def up
    change_column :line_items, :taxable, :boolean, default: true
  end

  def down
    change_column :line_items, :taxable, :boolean, default: nil
  end
end

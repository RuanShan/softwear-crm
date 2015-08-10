class GiveScaleToLineItemTemplateUnitPrice < ActiveRecord::Migration
  def change
    change_column :line_item_templates, :unit_price, :decimal, precision: 10, scale: 2
  end
end

class AddUpchargeFieldsToImprintable < ActiveRecord::Migration
  def change
    add_column :imprintables, :xxl_upcharge, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxl_upcharge, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxxl_upcharge, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxxxl_upcharge, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxxxxl_upcharge, :decimal, precision: 10, scale: 2
  end
end

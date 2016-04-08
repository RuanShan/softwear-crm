class AdjustScaleOnPercentages < ActiveRecord::Migration
  def change
    change_column :orders, :tax_rate, :decimal, precision: 10, scale: 4
    change_column :orders, :fee,      :decimal, precision: 10, scale: 4
  end
end

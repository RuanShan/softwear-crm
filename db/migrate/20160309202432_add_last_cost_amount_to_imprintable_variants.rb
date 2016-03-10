class AddLastCostAmountToImprintableVariants < ActiveRecord::Migration
  def change
    add_column :imprintable_variants, :last_cost_amount, :decimal, precision: 10, scale: 2
  end
end

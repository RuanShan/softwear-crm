class AddBaseUpchargeToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :base_upcharge, :decimal, precision: 10, scale: 2
  end
end

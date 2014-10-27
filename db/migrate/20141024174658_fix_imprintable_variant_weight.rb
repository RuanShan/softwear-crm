class FixImprintableVariantWeight < ActiveRecord::Migration
  def change
    change_column :imprintable_variants, :weight, :decimal, precision: 10, scale: 1
  end
end

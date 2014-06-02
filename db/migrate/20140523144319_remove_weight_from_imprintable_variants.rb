class RemoveWeightFromImprintableVariants < ActiveRecord::Migration
  def change
    remove_column :imprintable_variants, :weight, :string
  end
end

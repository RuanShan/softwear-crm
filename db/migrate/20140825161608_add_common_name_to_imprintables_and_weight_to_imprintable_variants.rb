class AddCommonNameToImprintablesAndWeightToImprintableVariants < ActiveRecord::Migration
  def change
    add_column :imprintables, :common_name, :string
    add_column :imprintable_variants, :weight, :decimal
  end
end

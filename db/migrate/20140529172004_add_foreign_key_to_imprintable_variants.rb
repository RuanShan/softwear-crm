class AddForeignKeyToImprintableVariants < ActiveRecord::Migration
  def change
    add_column :imprintable_variants, :size_id, :integer
    add_column :imprintable_variants, :color_id, :integer
  end
end

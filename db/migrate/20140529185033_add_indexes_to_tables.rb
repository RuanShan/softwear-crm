class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :imprintables, :style_id, :name => 'style_id_ix'
    add_index :colors, :imprintable_variant_id, :name => 'color_imprintable_variant_id_ix'
    add_index :styles, :brand_id, :name => 'brand_id_ix'
    add_index :sizes, :imprintable_variant_id, :name => 'size_imprintable_variant_id_ix'
  end
end

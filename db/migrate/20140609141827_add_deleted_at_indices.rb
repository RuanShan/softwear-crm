class AddDeletedAtIndices < ActiveRecord::Migration
  def change
    add_index :brands, :deleted_at
    add_index :colors, :deleted_at
    add_index :imprint_methods, :deleted_at
    add_index :imprintables, :deleted_at
    add_index :imprintable_variants, :deleted_at
    add_index :ink_colors, :deleted_at
    add_index :jobs, :deleted_at
    add_index :orders, :deleted_at
    add_index :print_locations, :deleted_at
    add_index :shipping_methods, :deleted_at
    add_index :sizes, :deleted_at
    add_index :stores, :deleted_at
    add_index :styles, :deleted_at
    add_index :users, :deleted_at
  end
end

class AddDeletedAtToTables < ActiveRecord::Migration
  def change
    remove_column :brands, :deleted_at
    add_column :brands, :deleted_at, :datetime
    add_index :brands, :deleted_at

    remove_column :imprintables, :deleted_at
    add_column :imprintables, :deleted_at, :datetime
    add_index :imprintables, :deleted_at

    remove_column :imprintable_variants, :deleted_at
    add_column :imprintable_variants, :deleted_at, :datetime
    add_index :imprintable_variants, :deleted_at

    remove_column :styles, :deleted_at
    add_column :styles, :deleted_at, :datetime
    add_index :styles, :deleted_at

    remove_column :sizes, :deleted_at
    add_column :sizes, :deleted_at, :datetime
    add_index :sizes, :deleted_at

    remove_column :colors, :deleted_at
    add_column :colors, :deleted_at, :datetime
    add_index :colors, :deleted_at
  end
end

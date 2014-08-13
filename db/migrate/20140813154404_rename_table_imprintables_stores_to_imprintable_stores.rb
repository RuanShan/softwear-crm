class RenameTableImprintablesStoresToImprintableStores < ActiveRecord::Migration
  def change
    rename_table :imprintables_stores, :imprintable_stores
    add_column :imprintable_stores, :id, :primary_key
    add_column :imprintable_stores, :created_at, :datetime
    add_column :imprintable_stores, :updated_at, :datetime
  end
end

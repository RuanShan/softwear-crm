class AddStoreLogoIdToStores < ActiveRecord::Migration
  def change
    add_column :stores, :logo_id, :integer
  end
end

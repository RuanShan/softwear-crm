class AddMarketplaceNameToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :marketplace_name, :string
  end
end

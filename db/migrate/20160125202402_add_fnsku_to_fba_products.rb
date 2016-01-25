class AddFnskuToFbaProducts < ActiveRecord::Migration
  def change
    add_column :fba_products, :fnsku, :string
  end
end

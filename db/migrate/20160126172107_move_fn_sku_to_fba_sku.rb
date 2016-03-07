class MoveFnSkuToFbaSku < ActiveRecord::Migration
  def change
    remove_column :fba_products, :fnsku, :string
    add_column :fba_skus, :fnsku, :string
    add_column :fba_skus, :asin, :string
  end
end

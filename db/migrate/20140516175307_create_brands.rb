class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :sku
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

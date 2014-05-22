class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string :name
      t.string :catalog_no
      t.text :description
      t.string :sku
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

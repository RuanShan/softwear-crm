class CreateFbaProducts < ActiveRecord::Migration
  def change
    create_table :fba_products do |t|
      t.string :name
      t.string :sku

      t.timestamps null: false
    end

    create_table :fba_skus do |t|
      t.references :fba_product, index: true, foreign_key: true
      t.string :sku
      t.references :imprintable_variant, index: true, foreign_key: true
      t.references :fba_job_template, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

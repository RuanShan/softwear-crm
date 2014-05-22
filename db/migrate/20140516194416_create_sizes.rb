class CreateSizes < ActiveRecord::Migration
  def change
    create_table :sizes do |t|
      t.string :name
      t.string :display_value
      t.string :sku
      t.integer :sort_order
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

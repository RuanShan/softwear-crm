class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :shipping_method_id
      t.integer :shipped_by_id
      t.integer :shippable_id
      t.string :shippable_type
      t.decimal :shipping_cost, scale: 2, precision: 10
      t.datetime :shipped_at
      t.string :tracking_number
      t.string :status
      t.string :name
      t.string :company
      t.string :attn
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country

      t.timestamps null: false
    end
  end
end

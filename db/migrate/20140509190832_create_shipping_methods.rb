class CreateShippingMethods < ActiveRecord::Migration
  def change
    create_table :shipping_methods do |t|
      t.string :name
      t.string :tracking_url
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string :email
      t.string :phone_number
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :twitter
      t.string :name
      t.datetime :valid_until_date
      t.datetime :estimated_delivery_date
      t.integer :salesperson_id
      t.integer :store_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

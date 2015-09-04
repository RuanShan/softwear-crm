class CreateInStoreCredits < ActiveRecord::Migration
  def change
    create_table :in_store_credits do |t|
      t.string :name
      t.string :customer_first_name
      t.string :customer_last_name
      t.string :customer_email
      t.decimal :amount
      t.text :description
      t.integer :user_id
      t.datetime :valid_until

      t.timestamps null: false
    end
  end
end

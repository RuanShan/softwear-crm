class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.integer :discountable_id
      t.string :discountable_type
      t.text :reason
      t.string :discount_method
      t.string :transaction_id
      t.integer :user_id
      t.integer :applicator_id
      t.string :applicator_type
      t.decimal :amount
      t.integer :order_id
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end

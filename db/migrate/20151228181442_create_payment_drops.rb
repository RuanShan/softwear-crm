class CreatePaymentDrops < ActiveRecord::Migration
  def change
    create_table :payment_drops do |t|
      t.decimal :cash_included, precision: 10, scale: 2
      t.text :difference_reason
      t.integer :salesperson_id, index: true
      t.integer :store_id, index: true

      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end

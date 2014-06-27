class AddPaymentsTable < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :order
      t.integer :salesperson_id
      t.belongs_to :store
      t.boolean :refunded
      t.decimal :amount, precision: 10, scale: 2
      t.text :refund_reason
      t.datetime :deleted_at
      t.string :cc_invoice_no
      t.string :cc_batch_no
      t.string :check_dl_no
      t.string :check_phone_no
      t.string :pp_transaction_id
      t.string :payment_method
      t.timestamps
    end
  end
end

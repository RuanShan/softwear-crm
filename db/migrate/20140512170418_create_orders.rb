class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :email
      t.string :firstname
      t.string :lastname
      t.string :company
      t.string :twitter
      t.string :name
      t.string :po
      t.datetime :in_hand_by
      t.string :terms
      t.boolean :tax_exempt
      t.string :tax_id_number
      t.boolean :needs_redo
      t.text :redo_reason
      t.string :sales_status
      t.string :delivery_method
      t.decimal :total
      t.datetime :deleted_at
      t.string :phone_number
    end
  end
end

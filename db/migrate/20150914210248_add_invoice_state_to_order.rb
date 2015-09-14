class AddInvoiceStateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_state, :string
    
    Order.all.each do |o|
      o.update_column(:invoice_state, :pending)
    end

  end
end

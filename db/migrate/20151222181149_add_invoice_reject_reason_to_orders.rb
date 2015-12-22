class AddInvoiceRejectReasonToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_reject_reason, :text
  end
end

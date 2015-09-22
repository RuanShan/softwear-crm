class AddFreshdeskProofTicketIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :freshdesk_proof_ticket_id, :integer, index: true
  end
end

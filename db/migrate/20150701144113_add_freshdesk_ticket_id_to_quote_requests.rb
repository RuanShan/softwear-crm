class AddFreshdeskTicketIdToQuoteRequests < ActiveRecord::Migration
  def change
    add_column :quote_requests, :freshdesk_ticket_id, :string
  end
end

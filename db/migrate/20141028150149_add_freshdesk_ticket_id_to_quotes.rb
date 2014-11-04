class AddFreshdeskTicketIdToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :freshdesk_ticket_id, :string
  end
end

class AddFreshdeskContactIdToQuoteRequest < ActiveRecord::Migration
  def change
    add_column :quote_requests, :freshdesk_contact_id, :integer
  end
end

class AddInsightlyContactIdToQuoteRequest < ActiveRecord::Migration
  def change
    add_column :quote_requests, :insightly_contact_id, :integer
  end
end

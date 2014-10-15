class AddStatusToQuoteRequests < ActiveRecord::Migration
  def change
    add_column :quote_requests, :status, :string
  end
end

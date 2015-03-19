class AddReasonToQuoteRequests < ActiveRecord::Migration
  def change
    add_column :quote_requests, :reason, :string
  end
end

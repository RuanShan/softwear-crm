class AddSalespersonToQuoteRequest < ActiveRecord::Migration
  def change
    add_column :quote_requests, :salesperson_id, :integer
  end
end

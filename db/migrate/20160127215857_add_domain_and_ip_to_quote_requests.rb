class AddDomainAndIpToQuoteRequests < ActiveRecord::Migration
  def change
    add_column :quote_requests, :domain, :string
    add_column :quote_requests, :ip_address, :string
  end
end

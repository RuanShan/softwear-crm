class AddPhoneNumberAndOrganizationToQuoteRequests < ActiveRecord::Migration
  def change
    add_column :quote_requests, :phone_number, :string
    add_column :quote_requests, :organization, :string
  end
end

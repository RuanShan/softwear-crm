class AddInsightlyOpportunityProfileIdToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :insightly_opportunity_profile_id, :integer
    add_column :quote_requests, :insightly_organisation_id, :integer
  end
end

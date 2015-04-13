class AddInsightlyApiKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :insightly_api_key, :string
  end
end

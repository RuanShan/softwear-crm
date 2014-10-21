class AddInitializedAtToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :initialized_at, :datetime
  end
end

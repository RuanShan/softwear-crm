class AddInformalToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :informal, :boolean
  end
end

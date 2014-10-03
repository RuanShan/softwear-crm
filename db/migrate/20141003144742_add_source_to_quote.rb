class AddSourceToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :quote_source, :string
  end
end

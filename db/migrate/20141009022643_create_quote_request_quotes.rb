class CreateQuoteRequestQuotes < ActiveRecord::Migration
  def change
    create_table :quote_request_quotes do |t|
      t.integer :quote_id
      t.integer :quote_request_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

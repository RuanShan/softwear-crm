class CreateQuoteRequestImprintables < ActiveRecord::Migration
  def change
    create_table :quote_request_imprintables do |t|
      t.integer :quote_request_id
      t.integer :imprintable_id
      t.integer :quantity

      t.timestamps null: false
    end
  end
end

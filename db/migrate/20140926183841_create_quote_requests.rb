class CreateQuoteRequests < ActiveRecord::Migration
  def change
    create_table :quote_requests do |t|
      t.string :name
      t.string :email
      t.decimal :approx_quantity
      t.datetime :date_needed
      t.string :description
      t.string :source
      
      t.timestamps
    end
  end
end

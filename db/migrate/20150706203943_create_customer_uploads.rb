class CreateCustomerUploads < ActiveRecord::Migration
  def change
    create_table :customer_uploads do |t|
      t.string :filename
      t.string :url
      t.integer :quote_request_id

      t.timestamps null: false
    end
  end
end

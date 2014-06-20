class CreateArtworkRequests < ActiveRecord::Migration
  def change
    create_table :artwork_requests do |t|
      t.text :description
      t.integer :artist_id
      t.integer :imprint_method_id
      t.integer :print_location_id
      t.integer :salesperson_id
      t.datetime :deadline
      t.string :artwork_status
      t.string   :file_file_name
      t.string   :file_content_type
      t.integer  :file_file_size
      t.datetime :file_updated_at
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

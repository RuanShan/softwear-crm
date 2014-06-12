class CreateArtworkRequests < ActiveRecord::Migration
  def change
    create_table :artwork_requests do |t|
      t.text :description
      t.integer :artist_id
      t.integer :imprint_method_id
      t.integer :print_location_id
      t.integer :salesperson_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

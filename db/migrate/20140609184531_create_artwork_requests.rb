class CreateArtworkRequests < ActiveRecord::Migration
  def change
    create_table :artwork_requests do |t|
      t.text     :description
      t.string   :file_file_name
      t.string   :file_content_type
      t.integer  :file_file_size
      t.datetime :file_updated_at
      t.datetime :deleted_at
      t.timestamps
    end
  end
end

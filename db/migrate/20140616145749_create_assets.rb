class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string   :name
      t.text     :description
      t.string   :file_file_name
      t.string   :file_content_type
      t.integer  :file_file_size
      t.datetime :file_updated_at
      t.timestamps
      t.integer  :artwork_request_id
    end
  end
end

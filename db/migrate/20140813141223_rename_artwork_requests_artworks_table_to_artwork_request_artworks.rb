class RenameArtworkRequestsArtworksTableToArtworkRequestArtworks < ActiveRecord::Migration
  def change
    rename_table :artwork_requests_artworks, :artwork_request_artworks
    add_column :artwork_request_artworks, :id, :primary_key
    add_column :artwork_request_artworks, :created_at, :datetime
    add_column :artwork_request_artworks, :updated_at, :datetime
  end
end

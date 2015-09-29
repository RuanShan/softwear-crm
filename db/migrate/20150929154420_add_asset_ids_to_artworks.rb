class AddAssetIdsToArtworks < ActiveRecord::Migration
  def change
    add_column :artworks, :artwork_id, :integer
    add_column :artworks, :preview_id, :integer
    add_column :assets, :allowed_content_type, :string
  end
end

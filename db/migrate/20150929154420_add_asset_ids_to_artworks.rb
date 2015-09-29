class AddAssetIdsToArtworks < ActiveRecord::Migration
  def up
    art = {}
    Artwork.unscoped.find_each do |artwork|
      art[artwork.id] = artwork.artwork
    end

    add_column :artworks, :artwork_id, :integer
    add_column :artworks, :preview_id, :integer
    add_column :assets, :allowed_content_type, :string

    Artwork.unscoped.find_each do |artwork|
      asset = art[artwork.id]
      next unless asset

      artwork.artwork = asset
      artwork.save(validate: false)
      asset.save(validate: false)
    end
  end

  def down
    remove_column :artworks, :artwork_id, :integer
    remove_column :artworks, :preview_id, :integer
    remove_column :assets, :allowed_content_type, :string
  end
end

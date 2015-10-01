class AddLocalFileLocationToArtworks < ActiveRecord::Migration
  def change
    add_column :artworks, :local_file_location, :string
  end
end

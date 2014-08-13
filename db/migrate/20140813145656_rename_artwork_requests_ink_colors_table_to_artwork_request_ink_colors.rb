class RenameArtworkRequestsInkColorsTableToArtworkRequestInkColors < ActiveRecord::Migration
  def change
    rename_table :artwork_requests_ink_colors, :artwork_request_ink_colors
    add_column :artwork_request_ink_colors, :id, :primary_key
    add_column :artwork_request_ink_colors, :created_at, :datetime
    add_column :artwork_request_ink_colors, :updated_at, :datetime
  end
end

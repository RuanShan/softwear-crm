class CreateArtworkRequestsInkColorsJoinTable < ActiveRecord::Migration
  def change
    create_table :artwork_requests_ink_colors, id: false do |t|
      t.integer :artwork_request_id
      t.integer :ink_color_id
    end
  end
end

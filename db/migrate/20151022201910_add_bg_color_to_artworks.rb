class AddBgColorToArtworks < ActiveRecord::Migration
  def change
    add_column :artworks, :bg_color, :string
  end
end

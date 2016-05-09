class AddRequiresArtworkToImprintMethods < ActiveRecord::Migration
  def up
    add_column :imprint_methods, :requires_artwork, :boolean
    ImprintMethod.unscoped.update_all requires_artwork: true
  end

  def down
    remove_column :imprint_methods, :requires_artwork, :boolean
  end
end

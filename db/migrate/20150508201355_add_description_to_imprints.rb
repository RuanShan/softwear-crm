class AddDescriptionToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :description, :text
  end
end

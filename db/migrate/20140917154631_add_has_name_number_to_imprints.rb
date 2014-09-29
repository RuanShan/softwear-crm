class AddHasNameNumberToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :has_name_number, :boolean
  end
end

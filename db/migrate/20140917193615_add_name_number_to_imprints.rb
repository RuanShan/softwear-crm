class AddNameNumberToImprints < ActiveRecord::Migration
  def change
    add_column :imprints, :name_number, :string
  end
end

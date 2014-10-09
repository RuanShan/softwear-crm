class AddDescriptionToNameNumber < ActiveRecord::Migration
  def change
    add_column :name_numbers, :description, :string
  end
end

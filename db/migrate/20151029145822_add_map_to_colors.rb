class AddMapToColors < ActiveRecord::Migration
  def change
    add_column :colors, :map, :string
  end
end

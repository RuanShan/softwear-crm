class AddCustomToInkColors < ActiveRecord::Migration
  def change
    add_column :ink_colors, :custom, :boolean
  end
end

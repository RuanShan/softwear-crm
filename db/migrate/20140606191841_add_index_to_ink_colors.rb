class AddIndexToInkColors < ActiveRecord::Migration
  def change
    add_index :ink_colors, :imprint_method_id
  end
end

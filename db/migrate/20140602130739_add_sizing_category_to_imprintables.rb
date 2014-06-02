class AddSizingCategoryToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :sizing_category, :string
  end
end

class RefactorImprintNameNumberRelation < ActiveRecord::Migration
  def change
    add_column :name_numbers, :imprint_id, :integer
    add_column :name_numbers, :imprintable_variant_id, :integer
    remove_column :name_numbers, :description, :string
  end
end

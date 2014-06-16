class AddFieldsToImprintable < ActiveRecord::Migration
  def change
    add_column :imprintables, :proofing_template_name, :text
    add_column :imprintables, :material, :string
    add_column :imprintables, :standard_offering, :boolean
  end
end

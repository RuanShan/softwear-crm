class CreateLineItemTemplates < ActiveRecord::Migration
  def change
    create_table :line_item_templates do |t|
      t.string  :name
      t.text    :description
      t.string  :url
      t.decimal :unit_price

      t.timestamps null: false
    end
  end
end

class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.string :name
      t.integer :quantity
      t.boolean :taxable
      t.text :description

      t.belongs_to :jobs, index: true
    end
    add_column :line_items, :unit_price, :decimal, precision: 10, scale: 2
  end
end

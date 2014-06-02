class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.string :name
      t.integer :quantity
      t.decimal :unit_price
      t.boolean :taxable
      t.text :description

      t.belongs_to :jobs, index: true
    end
  end
end

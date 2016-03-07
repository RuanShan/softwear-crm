class CreateCosts < ActiveRecord::Migration
  def change
    create_table :costs do |t|
      t.string :cotable_type
      t.string :costable_id
      t.string :type
      t.text :description
      t.integer :owner_id
      t.decimal :time, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps null: false
    end
    add_index :costs, :cotable_type
    add_index :costs, :costable_id
    add_index :costs, :owner_id
  end
end

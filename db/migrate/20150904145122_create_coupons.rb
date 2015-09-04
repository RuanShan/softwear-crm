class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :name
      t.string :calculator
      t.decimal :value
      t.date :valid_until
      t.date :valid_from

      t.timestamps null: false
    end

    add_index :coupons, :code
  end
end

class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :name
      t.string :calculator
      t.decimal :value
      t.datetime :valid_until
      t.datetime :valid_from

      t.timestamps null: false
    end

    add_index :coupons, :code
  end
end

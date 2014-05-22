class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string :name
      t.string :sku
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

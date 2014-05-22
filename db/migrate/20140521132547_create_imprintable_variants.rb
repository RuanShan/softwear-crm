class CreateImprintableVariants < ActiveRecord::Migration
  def change
    create_table :imprintable_variants do |t|
      t.integer :imprintable_id
      t.string :weight
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

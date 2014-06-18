class CreateImprints < ActiveRecord::Migration
  def change
    create_table :imprints do |t|
      t.belongs_to :print_location
      t.belongs_to :job
      t.decimal :ideal_width
      t.decimal :ideal_height

      t.datetime :deleted_at
      t.timestamps
    end
  end
end

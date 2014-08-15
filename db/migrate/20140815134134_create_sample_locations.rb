class CreateSampleLocations < ActiveRecord::Migration
  def change
    create_table :sample_locations do |t|
      t.belongs_to :imprintable
      t.belongs_to :store
    end
  end
end

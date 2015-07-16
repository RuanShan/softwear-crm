class CreatePrintLocationImprintables < ActiveRecord::Migration
  def change
    create_table :print_location_imprintables do |t|
      t.integer :imprintable_id
      t.integer :print_location_id
      t.decimal :max_imprint_width
      t.decimal :max_imprint_height

      t.timestamps null: false
    end

    Imprintable.find_each do |imprintable|
      ImprintMethodImprintable.where(imprintable_id: imprintable.id).find_each do |join|
        next if join.imprint_method.nil?
        print_location_id = join.imprint_method.print_locations.pluck(:id).first

        unless print_location_id.nil?
          PrintLocationImprintable.create(
            imprintable_id: imprintable.id,
            print_location_id: join.imprint_method.print_locations.pluck(:id).first
          )
        end
      end
    end
  end
end

class CreatePricingOptionValuesAndTypes < ActiveRecord::Migration
  def change
    create_table :pricing_option_types do |t|
      t.integer :imprint_method_id, index: true
      t.string :name
    end

    create_table :pricing_option_values do |t|
      t.integer :option_type_id, index: true
      t.string :value
    end

    create_table :pricing_imprint_option_values do |t|
      t.integer :imprint_id, index: true
      t.integer :pricing_option_value_id, index: true
    end
  end
end

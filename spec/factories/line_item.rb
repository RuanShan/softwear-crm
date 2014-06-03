FactoryGirl.define do
  factory :line_item do
    unit_price 10.50
    quantity 3

    factory :non_imprintable_line_item do
      name 'Test Non-Imprintable'
      description 'Incredibly informative text'
      imprintable_variant_id nil
    end

    factory :imprintable_line_item do
      imprintable_variant { |i| i.association :valid_imprintable_variant }
    end
  end
end
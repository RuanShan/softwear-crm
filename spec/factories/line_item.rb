FactoryGirl.define do
  factory :line_item do
    unit_price 10.50
    quantity 3

    factory :non_imprintable_line_item do
      sequence(:name) { |n| "line_item_#{n}" }
      description 'Incredibly informative text'
      taxable false
      imprintable_variant_id nil
    end

    factory :taxable_non_imprintable_line_item do
      sequence(:name) { |n| "taxable_li_#{n}" }
      description 'Taxable'
      taxable true
      imprintable_variant_id nil
    end

    factory :imprintable_line_item do
      imprintable_variant { |i| i.association :associated_imprintable_variant }
    end
  end

  factory :blank_line_item, class: LineItem do

  end
end
FactoryGirl.define do
  factory :blank_line_item, class: LineItem do
    factory :line_item do
      quantity 3

      factory :non_imprintable_line_item do
        sequence(:name) { |n| "line_item_#{n}" }
        description 'Incredibly informative text'
        taxable false
        unit_price 10.50
      end

      factory :taxable_non_imprintable_line_item do
        sequence(:name) { |n| "taxable_li_#{n}" }
        description 'Taxable'
        taxable true
        unit_price 10.50
      end

      factory :imprintable_line_item do
        imprintable_object { |i| i.association :associated_imprintable_variant }
        decoration_price 8.50
        imprintable_price 2.50
      end

      factory :imprintable_quote_line_item do
        imprintable_object { |i| i.association :associated_imprintable }
        decoration_price 8.50
        imprintable_price 2.50
      end
    end
  end
end

FactoryGirl.define do
  factory :valid_brand, class: Brand do
    sequence(:name) { |n| "brand_#{n}" }
    sequence(:sku) { |n| (n %= 100) < 10 ? "0#{n}" : n }
  end

  factory :invalid_brand, class: Brand do
    name nil
    sku nil
  end
end

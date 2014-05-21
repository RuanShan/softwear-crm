FactoryGirl.define do
  factory :valid_brand, class: Brand do
    sequence(:name) { |n| "brand_#{n}" }
    sequence(:sku) { |n| "sku_#{n}" }
  end
end
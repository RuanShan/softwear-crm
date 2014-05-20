FactoryGirl.define do
  factory :valid_brand, class: Brand do
    sequence(:name) { |n| "color_#{n}" }
    sequence(:sku) { |n| "sku_#{n}" }
  end
end
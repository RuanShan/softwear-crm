FactoryGirl.define do
  factory :valid_size, class: Size do
    sequence(:name) { |n| "size_#{n}" }
    sequence(:sku) { |n| "sku_#{n}" }
    sort_order 1
  end
end
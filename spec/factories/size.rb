FactoryGirl.define do
  factory :valid_size, class: Size do
    sequence(:name) { |n| "size_#{n}" }
    sequence(:display_value) { |n| "display_value_#{n}"}
    sequence(:sku) { |n| "sku_#{n}" }
    sequence(:sort_order) { |n| n }
  end
end

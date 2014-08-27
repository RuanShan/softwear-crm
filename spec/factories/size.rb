FactoryGirl.define do
  factory :blank_size, class: Size do

    factory :valid_size do
      sequence(:name) { |n| "size_#{n}" }
      sequence(:display_value) { |n| "display_value_#{n}" }
      sequence(:sku) { |n| (n %= 100) < 10 ? "0#{n}" : n }
      sequence(:sort_order) { |n| n }
    end
  end
end

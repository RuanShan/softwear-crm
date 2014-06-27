FactoryGirl.define do
  factory :valid_size, class: Size do
    sequence(:name) { |n| "size_#{n}" }
    sequence(:display_value) { |n| "display_value_#{n}"}
    sequence(:sku) { |n|
      n %= 100
      if n < 10
        "0#{n}"
      else
        n
      end
    }
    sequence(:sort_order) { |n| n }
  end


end

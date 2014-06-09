FactoryGirl.define do
  factory :valid_brand, class: Brand do
    sequence(:name) { |n| "brand_#{n}" }
    sequence(:sku) { |n|
      if n < 10
        "0#{n}"
      else
        n
      end
    }
  end
end
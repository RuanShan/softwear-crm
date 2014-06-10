FactoryGirl.define do
  factory :valid_brand, class: Brand do
    sequence(:name) { |n| "brand_#{n}" }
    sequence(:sku) { |n|
      n = n % 100
      if n < 10
        x = "0#{n}"
        x
      else
        n
      end
    }
  end
end

FactoryGirl.define do
  factory :blank_brand, class: Brand do

    factory :valid_brand do
      sequence(:name) { |n| "brand_#{n}" }
      sequence(:sku) { |n| (n %= 100) < 10 ? "0#{n}" : n }
    end
  end
end

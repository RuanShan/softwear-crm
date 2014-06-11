FactoryGirl.define do
  factory :style do
    sequence(:name) { |n| "style_#{n}" }
    sequence(:sku) { |n|
      n %= 100
      if n < 10
        "0#{n}"
      else
        n
      end
    }
    sequence(:catalog_no) { |n| (1234+n).to_s }
    description 'description'

    factory :valid_style do
      before(:create) do |style|
        brand = FactoryGirl.create(:valid_brand)
        style.brand = brand
        style.brand_id = brand.id
      end
    end

    factory :associated_style do
      brand { |b| b.association(:valid_brand) }
    end
  end
end

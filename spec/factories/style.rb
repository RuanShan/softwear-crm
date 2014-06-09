FactoryGirl.define do
  factory :valid_style, class: Style do
    before(:create) do |style|
      brand = FactoryGirl.create(:valid_brand)
      style.brand = brand
      style.brand_id = brand.id
    end
    sequence(:name) { |n| "style_#{n}" }
    sequence(:sku) { |n|
      if n < 10
        "0#{n}"
      else
        n
      end
    }
    catalog_no '1234'
    description 'description'
  end
end

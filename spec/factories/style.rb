FactoryGirl.define do
  factory :valid_style, class: Style do
    sequence(:name) { |n| "style_#{n}" }
    sequence(:sku) { |n| "sku_#{n}" }
    catalog_no '1234'
    description 'description'
  end
end
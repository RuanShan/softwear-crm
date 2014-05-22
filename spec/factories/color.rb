FactoryGirl.define do
  factory :valid_color, class: Color do
    sequence(:name) { |n| "color_#{n}" }
    sequence(:sku) { |n| "sku_#{n}" }
  end
end
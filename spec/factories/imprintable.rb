FactoryGirl.define do
  factory :valid_imprintable, class: Imprintable do
    name 'Item'
    catalog_number '12'
    description 'description'
  end
end
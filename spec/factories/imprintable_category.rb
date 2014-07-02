FactoryGirl.define do
  sequence :category do |n|
    ['Tees & Tanks', 'Sweatshirts & Fleece', 'Business & Industrial Wear', 'Jackets',
     'Headwear & Bags', 'Athletics', 'Fashionable', 'Youth', 'Something Different', 'What\'s Least Expensive'][n%10]
  end

  factory :imprintable_category, class: ImprintableCategory do
    category { generate :category }
    imprintable { |s| s.association :valid_imprintable }
  end
end

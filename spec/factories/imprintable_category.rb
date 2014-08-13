FactoryGirl.define do
  sequence :category_name do |n|
    ['Tees & Tanks', 'Sweatshirts & Fleece', 'Business & Industrial Wear', 'Jackets',
     'Headwear & Bags', 'Athletics', 'Fashionable', 'Youth', 'Something Different', 'What\'s Least Expensive'][n%10]
  end

  factory :blank_imprintable_category, class: ImprintableCategory do

    factory :imprintable_category do
      name { generate :category_name }
      imprintable { |s| s.association :valid_imprintable }
    end
  end
end

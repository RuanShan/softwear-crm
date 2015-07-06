FactoryGirl.define do
  sequence :store_name do |n|
    ['Ypsilanti Tees', 'Ann Arbor Tees'][n%2]
  end

  factory :blank_store, class: Store do
    factory :valid_store do
      name { generate :store_name }
    end
  end
end

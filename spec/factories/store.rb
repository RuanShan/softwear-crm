FactoryGirl.define do
  sequence :store_name do |n|
    %w(Ypsilanti\ Tees Ann\ Arbor\ Tees)[n%2]
  end

  factory :valid_store, class: Store do
    name { generate :store_name }
  end
end
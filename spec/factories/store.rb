FactoryGirl.define do
  sequence :store_name do |n|
    ['Ypsilanti Tees', 'Ann Arbor Tees'][n%2]
  end

  factory :blank_store, class: Store do
    factory :valid_store do
      name { generate :store_name }
      address_1 'Addr 1'
      address_2 'Addr 2'
      city 'Ann Arbor'
      state 'MI'
      zipcode 'zipcode'
      country 'USA' 
      phone '800-555-1212'
      sales_email 'sales@softwearcrm.com'
      logo { |l| l.association(:valid_asset) }
    end

    initialize_with { Store.find_or_create_by(name: name) }

  end
end

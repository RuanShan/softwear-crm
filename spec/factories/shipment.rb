FactoryGirl.define do
  factory :shipment do
    name 'Chet McGillicutty'
    address_1 "A street"
    city "A City"
    state "MI"
    zipcode "A Zipcode"
    shipping_method { |s| s.association(:shipping_method) }
    shippable {|s| s.association(:order) }
  end
end

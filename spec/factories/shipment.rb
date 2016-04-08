FactoryGirl.define do
  factory :shipment do
    name 'Chet McGillicutty'
    address_1 "A street"
    city "A City"
    state "MI"
    zipcode "A Zipcode"
    time_in_transit 1.0
    shipping_method { |s| s.association(:shipping_method) }
    shippable {|s| s.association(:order) }
    
    factory :ann_arbor_tees_delivery_shipment do 
      shipping_method { |s| s.association(:ann_arbor_tees_shipping_method) }
    end

    factory :shipment_with_tracking_number_shipping_url do
      tracking_number 12345678910
      shipping_method { |s| s.association(:tracking_number_shipping) }
    end
  end

end

FactoryGirl.define do
  factory :valid_shipping_method, class: ShippingMethod do
    name 'Shipping Method Name'
    tracking_url 'http://www.tracking-site.com'

    factory :shipping_method
    
    factory :ann_arbor_tees_shipping_method do 
      name 'Ann Arbor Tees Delivery'
    end

    factory :tracking_number_shipping do
      tracking_url 'http://www.tracking-site.com/:tracking_number'
    end
  end
end

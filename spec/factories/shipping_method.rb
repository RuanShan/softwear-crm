FactoryGirl.define do
  factory :valid_shipping_method, class: ShippingMethod do
    name 'Shipping Method Name'
    tracking_url 'http://www.tracking-site.com'

    factory :shipping_method
  end
end

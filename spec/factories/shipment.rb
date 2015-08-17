FactoryGirl.define do
  factory :shipment do
    shipping_method { |s| s.association(:shipping_method) }
  end
end

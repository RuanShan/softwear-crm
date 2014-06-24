FactoryGirl.define do
  factory :valid_payment, class: Payment do
    order { |o| o.association(:valid_order) }
    amount '100.50'
  end
end

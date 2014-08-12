FactoryGirl.define do
  factory :valid_payment, class: Payment do
    order { |o| o.association(:order) }
    store { |s| s.association(:valid_store) }
    amount '10.00'
  end

  factory :refunded_payment, class: Payment do
    order { |o| o.association(:order) }
    store { |s| s.association(:valid_store) }
    amount '10.00'
    refunded true
    refund_reason 'for testing purposes'
  end
  factory :blank_payment, class: Payment do

  end
end

FactoryGirl.define do
  factory :blank_payment, class: Payment do

    factory :valid_payment do
      order { |o| o.association(:order) }
      store { |s| s.association(:valid_store) }
      amount '10.00'
    end
  end
end

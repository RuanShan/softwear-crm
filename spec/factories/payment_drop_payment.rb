FactoryGirl.define do
  factory :payment_drop_payment, class: PaymentDropPayment do
    payment {|t| t.association(:valid_payment) }
  end
end

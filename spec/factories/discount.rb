FactoryGirl.define do
  factory :discount do
    discount_method 'Cash'
    reason 'whatever'
    amount 0

    factory :discount_with_order do
      discountable { |x| x.association(:order_with_job) }
    end

    factory :refund do
      discount_method 'RefundPayment'
      applicator_type 'Refund'
    end
  end
end

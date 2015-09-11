FactoryGirl.define do
  factory :discount do
    discount_method 'Cash'
    reason 'whatever'
    amount 0

    factory :discount_with_order do
      discountable { |x| x.association(:order_with_job) }
    end
  end
end

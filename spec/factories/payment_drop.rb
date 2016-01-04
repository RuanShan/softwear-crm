FactoryGirl.define do
  factory :payment_drop, class: PaymentDrop do
    salesperson {|pd| pd.association(:user) }
    store {|pd| pd.association(:valid_store) }
    cash_included 0.0
    check_included 0.0
  end
end

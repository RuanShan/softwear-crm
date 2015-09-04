FactoryGirl.define do
  factory :in_store_credit, class: InStoreCredit do
    sequence(:name) { |n| "ISC-#{n}" }
    customer_first_name "Test"
    customer_last_name "Person"
    customer_email "test.p@gmail.com"
    amount 15.5
    description "This is just a test. Nobody cares."
    valid_until { 3.days.from_now }
    user { |u| u.association(:user) }
  end
end

FactoryGirl.define do
  factory :blank_quote_request, class: QuoteRequest do

    factory :quote_request do
      sequence(:name) { |n| "Someone #{n}" }
      sequence(:email) { |n| "someone_#{n}@somesite.com" }
      approx_quantity 10
      date_needed Time.now + 2.days
      sequence(:description) { |n| "This is the order from person #{n}" }
      source "Probably the wordpress site"
    end
  end
end

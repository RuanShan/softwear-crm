FactoryGirl.define do
  factory :blank_quote_request, class: QuoteRequest do

    factory :quote_request do
      sequence(:name) { |n| "Someone #{n}" }
      sequence(:email) { |n| "someone_#{n}@somesite.com" }
      approx_quantity 10
      date_needed Time.now + 2.days
      sequence(:description) { |n| "This is the order from person #{n}" }
      source "Probably the wordpress site"

      factory :valid_quote_request_with_salesperson do
        before(:create) do |quote_request|
          quote_request.salesperson_id = create(:alternate_user).id
        end

        factory :valid_quote_request_with_quotes do
          after(:create) do |quote_request|
            2.times { quote_request.quotes << create(:valid_quote) }
          end
        end
      end
    end
  end
end

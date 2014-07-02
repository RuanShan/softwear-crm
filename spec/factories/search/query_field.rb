FactoryGirl.define do
  factory :query_field, class: Search::QueryField do
    factory :query_order_name_field do
      name 'name'
      query_model { |m| m.association(:query_order_model) }
    end
    factory :query_order_email_field do
      name 'email'
      query_model { |m| m.association(:query_order_model) }
    end
  end
end
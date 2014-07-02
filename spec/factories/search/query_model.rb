FactoryGirl.define do
  factory :query_model, class: Search::QueryModel do
    factory :query_order_model do
      name 'Order'
    end
    factory :query_job_model do
      name 'Job'
    end
  end
end
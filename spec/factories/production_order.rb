FactoryGirl.define do
  factory :production_order, class: 'Production::Order' do
    name 'Some Production Order'
    deadline 5.days.from_now
  end

  factory :production_job, class: 'Production::Job' do
    name 'Some prod job'
  end
end

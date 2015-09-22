FactoryGirl.define do
  factory :production_order, class: 'Production::Order' do
    name 'Some Production Order'
    deadline 5.days.from_now
  end
end

FactoryGirl.define do
  factory :production_order, class: 'Production::Order' do
    name 'Some Production Order'
    deadline 5.days.from_now
    
    factory :production_order_with_job do 
      jobs [ create(:production_job) ]
    end

    factory :production_order_with_post_production_trains do 
      post_production_trains []
    end
  end

  factory :production_job, class: 'Production::Job' do
    name 'Some prod job'
  end
end

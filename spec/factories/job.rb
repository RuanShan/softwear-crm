FactoryGirl.define do
  factory :empty_job, class: Job do
    factory :job do
      sequence(:name) { |s| "Test Job #{s}" }
      description 'Here is the test job description.'
      order { |o| o.association(:order) }
    end
  end
end
FactoryGirl.define do
  factory :blank_job, class: Job do

    factory :job do
      sequence(:name) { |s| "Test Job #{s}" }
      description 'Here is the test job description.'
      jobbable { |o| o.association(:order) }
    end

    factory :quote_job do
      sequence(:name) { |s| "Test Job #{s}" }
      description 'Here is the test job description.'
      jobbable { |o| o.association(:quote) }
    end
  end
end

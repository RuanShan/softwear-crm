FactoryGirl.define do
	factory :job, class: Job do
		sequence(:name) { |s| "Test Job #{s}" }
		description 'Here is the test job description.'
	end
end
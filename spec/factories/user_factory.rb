FactoryGirl.define do
	factory :user do
		firstname 'Test'
		lastname 'User'
		email 'nobody@annarbortees.com'
	end
end

FactoryGirl.modify do
	factory :user do
		after(:build) { |u| u.password_confirmation = u.password = 'pw4test' }
	end
end
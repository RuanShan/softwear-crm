FactoryGirl.define do
	factory :user do
		firstname 'Test'
		lastname 'User'
		email 'nobody@annarbortees.com'
		after(:build) { |u| u.password_confirmation = u.password = 'pw4test' }
	end
end

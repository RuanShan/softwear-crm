FactoryGirl.define do
	factory :user do
		firstname 'Test'
		lastname 'User'
		email 'nobody@annarbortees.com'
		password '1234567890'

		factory :alternate_user do
			firstname 'First'
			lastname 'Last'
			email 'testing@softwearcrm.com'
		end

		after(:create) { |u| u.confirm! }
	end
end

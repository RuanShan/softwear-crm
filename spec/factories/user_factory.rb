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
    before(:create) { |u|
      store = FactoryGirl.create(:valid_store)
      u.store = store
      u.store_id = store.id
    }
	end
end

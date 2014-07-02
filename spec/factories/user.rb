FactoryGirl.define do
	factory :user do
		firstname 'Test'
		sequence(:lastname) { |n| "Last_#{n}" }
		sequence(:email) { |n| "user_email_#{n}@gmail.com" }
		password '1234567890'

		factory :alternate_user do
			firstname 'First'
			sequence(:lastname) { |n| "Last_#{n}" }
			sequence(:email) { |n| "user_email_#{n}@umich.edu" }
		end

		after(:create) { |u| u.confirm! }
    before(:create) { |u|
      store = FactoryGirl.create(:valid_store)
      u.store = store
      u.store_id = store.id
    }
  end

  factory :blank_user, class: User do

  end
end

FactoryGirl.define do
  factory :blank_user, class: User do

    factory :user do
      first_name 'Test_First'
      sequence(:last_name) { |n| "Test_Last_#{n}" }
      sequence(:email) { |n| "user_email_#{n}@hotmail.com" }
      password '1234567890'

      factory :alternate_user do
        first_name 'Test_First'
        sequence(:last_name) { |n| "Test_Alternate_Last_#{n}" }
        sequence(:email) { |n| "alternate_user_email_#{n}@umich.edu" }
      end

      after(:create) { |u| u.confirm }
      before(:create) { |u|
        store = FactoryGirl.create(:valid_store)
        u.store = store
        u.store_id = store.id
      }
    end
  end
end

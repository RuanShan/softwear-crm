FactoryGirl.define do
  factory :blank_user, class: User do

    factory :user do
      sequence(:id) { |n| n + 1 }
      first_name 'Test_First'
      sequence(:last_name) { |n| "Test_Last_#{n}" }
      sequence(:email) { |n| "user_email_#{n}@hotmail.com" }
      roles []

      initialize_with do
        new(
          id:         id,
          first_name: first_name,
          last_name:  last_name,
          email:      email
        )
      end

      factory :alternate_user do
        first_name 'Test_First'
        sequence(:last_name) { |n| "Test_Alternate_Last_#{n}" }
        sequence(:email) { |n| "alternate_user_email_#{n}@umich.edu" }
      end

      before(:create) do |u|
        u.instance_variable_set(:@persisted, true)
        store = FactoryGirl.create(:valid_store)
        u.attributes.store_id = store.id
        u.attributes.save!
      end
      after(:create) do |u|
        spec_users << u if try(:spec_users)
      end
    end
  end
end

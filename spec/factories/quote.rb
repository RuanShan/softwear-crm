FactoryGirl.define do
  factory :blank_quote, class: Quote do

    factory :valid_quote do
      sequence(:email) { |n| "email_#{n}@testing.com" }
      name 'Test Quote'
      first_name 'test'
      last_name 'mctesterson'
      valid_until_date Time.now + 1.day
      shipping '0'
      phone_number '1234569871'
      estimated_delivery_date Time.now + 1.day
      salesperson { |s| s.association(:user) }
      store { |st| st.association(:valid_store) }
      line_item_groups { |l| [l.association(:line_item_group_with_line_items)] }
    end
  end
end

FactoryGirl.define do
  factory :blank_quote, class: Quote do

    factory :valid_quote do
      name 'Test Quote'
      company 'Tester Co. Inc. LLC'
      valid_until_date Time.now + 1.day
      shipping '0'
      quote_source 'Other'
      estimated_delivery_date Time.now + 1.day
      informal true
      salesperson { |s| s.association(:user) }
      store { |st| st.association(:valid_store) }
      contact { |c| c.association(:crm_contact) }
    end
  end
end

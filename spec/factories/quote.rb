FactoryGirl.define do
  factory :valid_quote, class: Quote do
    email 'test@example.com'
    first_name 'test'
    last_name 'mctesterson'
    valid_until_date Time.now + 1.day
    estimated_delivery_date Time.now + 1.day
    salesperson { |s| s.association(:user) }
    store { |st| st.association(:valid_store) }
    line_items { |li| [
                        li.association(:non_imprintable_line_item),
                        li.association(:non_imprintable_line_item)
                      ] }
  end
end

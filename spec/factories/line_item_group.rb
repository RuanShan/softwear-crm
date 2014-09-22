FactoryGirl.define do
  factory :blank_line_item_group, class: LineItemGroup do

    factory :line_item_group do
      sequence(:name) { |s| "Test line_item_group #{s}" }
      description 'Here is the test line_item_group description.'
    end
  end
end

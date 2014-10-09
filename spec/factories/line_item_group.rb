FactoryGirl.define do
  factory :blank_line_item_group, class: LineItemGroup do

    factory :line_item_group do
      sequence(:name) { |s| "Test line_item_group #{s}" }
      description 'Here is the test line_item_group description.'
    end

    factory :line_item_group_with_line_items do
      line_items { |li| [
        li.association(:imprintable_line_item),
        li.association(:imprintable_line_item)
      ] }
    end
  end
end

FactoryGirl.define do

  factory :valid_imprint_method, class: ImprintMethod do
    sequence(:name) { |n| "name_#{n}" }
  end

  factory :valid_imprint_method_with_color_and_location, class: ImprintMethod do
    sequence(:name) { |n| "name_#{n}" }
    after(:create) {|im| create(:valid_ink_color, imprint_method_id: im.id)}
    after(:create) {|pl| create(:valid_print_location, imprint_method_id: pl.id)}
  end
end
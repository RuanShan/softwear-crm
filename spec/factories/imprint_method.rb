FactoryGirl.define do
  factory :blank_imprint_method, class: ImprintMethod do

    factory :valid_imprint_method do
      sequence(:name) { |n| "name_#{n}" }

      factory :valid_imprint_method_with_color_and_location do
        after(:create) { |im| ImprintMethodInkColor.create!(imprint_method_id: im.id, ink_color_id: create(:valid_ink_color).id) }
        after(:create) { |pl| create(:valid_print_location, imprint_method_id: pl.id) }
      end

      factory :name_number_imprint_method do
        name 'Name/Number'
      end
    end
  end
end

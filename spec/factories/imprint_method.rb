FactoryGirl.define do
  factory :blank_imprint_method, class: ImprintMethod do

    factory :valid_imprint_method do
      sequence(:name) { |n| "name_#{n}" }

      factory :valid_imprint_method_with_color_and_location do
        after(:create) do |im|
          ImprintMethodInkColor.create!(imprint_method_id: im.id, ink_color_id: create(:ink_color).id)
          create(:valid_print_location, imprint_method_id: im.id)
        end
      end

      factory :name_number_imprint_method do
        name 'Name/Number'
      end

      factory :dtg_imprint_method do 
        name 'Digital Print - Non-White (DTG-NW)'
      end
      
      factory :embroidery_imprint_method do 
        name 'In-House Embroidery'
      end
      
      factory :screen_print_imprint_method do 
        name 'Screen Print'
      end
    end
  end
end

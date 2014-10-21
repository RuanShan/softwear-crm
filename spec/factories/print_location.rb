FactoryGirl.define do
  sequence :print_location_name do |n|
    a=%w(Back Front Left\ Chest Right\ Chest)
    a[n%a.count]
  end

  factory :blank_print_location, class: PrintLocation do

    factory :print_location do
      name { generate :print_location_name }
      max_height 5.5
      max_width 5.5

      factory :valid_print_location do
        imprint_method { |pl| pl.association(:valid_imprint_method) }
      end
    end
  end
end

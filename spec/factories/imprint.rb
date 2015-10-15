FactoryGirl.define do
  factory :blank_imprint, class: Imprint do
    description '1-CF'

    factory :valid_imprint do
      job { |j| j.association(:job) }
      print_location { |p| p.association(:print_location) }

      factory :imprint_with_name_number do
        has_name_number true
        print_location { |p| p.association(:print_location_with_name_number) }
      end
    end
  end
end

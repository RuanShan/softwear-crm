FactoryGirl.define do
  factory :blank_imprint, class: Imprint do
    description '1-CF'

    factory :valid_imprint do
      job { |j| j.association(:job) }
      print_location { |p| p.association(:print_location) }

      factory :imprint_without_job do
        job nil
        print_location { |p| p.association(:valid_print_location) }
      end

      factory :imprint_with_name_number do
        has_name_number true
        name_number true
        print_location { |p| p.association(:print_location_with_name_number) }
        name_format 'Name Format'
        number_format 'Number Format'
      end
    end
  end
end

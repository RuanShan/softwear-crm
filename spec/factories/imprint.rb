FactoryGirl.define do
  factory :blank_imprint, class: Imprint do

    factory :valid_imprint do
      job { |j| j.association(:job) }
      print_location { |p| p.association(:print_location) }
    end
  end
end

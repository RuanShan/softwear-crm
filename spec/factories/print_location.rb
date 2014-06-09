FactoryGirl.define do
  factory :print_location, class: PrintLocation do
    name 'Back'
    max_height 5.5
    max_width 5.5

    factory :valid_print_location do
      imprint_method { |pl| pl.association(:valid_imprint_method) }
    end
  end
end
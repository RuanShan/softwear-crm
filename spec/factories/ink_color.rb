FactoryGirl.define do
  factory :blank_ink_color, class: InkColor do

    factory :valid_ink_color do
      name 'Red'
      imprint_method { |ic| ic.association(:valid_imprint_method) }
    end
  end
end

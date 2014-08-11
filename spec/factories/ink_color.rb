FactoryGirl.define do
  factory :valid_ink_color, class: InkColor do
    name 'Red'
    imprint_method { |ic| ic.association(:valid_imprint_method) }
  end
end

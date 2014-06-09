FactoryGirl.define do
  factory :ink_color, class: InkColor do
    name 'Red'

    factory :valid_ink_color do
      imprint_method { |ic| ic.association(:valid_imprint_method) }
    end
  end
end
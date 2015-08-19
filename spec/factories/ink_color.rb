FactoryGirl.define do
  factory :blank_ink_color, class: InkColor do

    factory :ink_color do
      sequence(:name) { |n| %w(Red Blue Yellow Green Orange Purple Brown Black White Cyan)[n] }
    end

    factory :valid_ink_color do
      name 'Red'
      imprint_method { |ic| ic.association(:valid_imprint_method) }
    end
  end
end

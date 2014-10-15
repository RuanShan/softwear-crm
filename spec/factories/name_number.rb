FactoryGirl.define do
  factory :blank_name_number, class: NameNumber do
    factory :name_number do
      imprint { |i| i.association(:valid_imprint) }
      imprintable_variant { |iv| iv.association(:valid_imprintable_variant) }
      name 'Test Name'
      number 33
    end
  end
end

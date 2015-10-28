FactoryGirl.define do
  factory :blank_name_number, class: NameNumber do
    factory :number_12 do 
      number '12'
    end
    
    factory :number_33 do 
      number '33'
    end

    factory :number_39 do 
      number '39'
    end
    
    factory :name_number do
      imprint { |i| i.association(:valid_imprint) }
      imprintable_variant { |iv| iv.association(:valid_imprintable_variant) }
      name 'Test Name'
      number 33
    end
  end
end

FactoryGirl.define do
  factory :blank_name_number, class: NameNumber do
    factory :name_number do
      name 'Test Name'
      number 33
    end
  end
end
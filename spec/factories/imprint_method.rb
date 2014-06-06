FactoryGirl.define do
  sequence :production_name do |n|
    ['Production Method Name', 'Production Method Name 2'][n%2]
  end

  factory :valid_imprint_method, class: ImprintMethod do
    name 'Imprint Method'
    production_name { generate :production_name }
  end

  factory :valid_imprint_method_with_color, class: ImprintMethod do
    name 'Imprint Method'
    production_name { generate :production_name }
    after(:create) {|im| create(:valid_ink_color, imprint_method_id: im.id)}
  end
end
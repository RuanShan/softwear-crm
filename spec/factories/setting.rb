FactoryGirl.define do
  factory :valid_setting, class: Setting do
    name 'Name'
    val 'Val'
    encrypted false
  end
end

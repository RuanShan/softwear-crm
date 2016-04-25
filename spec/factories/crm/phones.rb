FactoryGirl.define do
  factory :crm_phone, :class => 'Crm::Phone' do
    number '555-555-1212'
    primary true

    factory :crm_phone_with_extension do
      extension '123'
    end
  end

end

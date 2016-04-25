FactoryGirl.define do
  factory :crm_email, :class => 'Crm::Email' do
    address 'sample@example.com'
    primary true

  end

end

FactoryGirl.define do
  factory :crm_contact, :class => 'Crm::Contact' do
    sequence :first_name do |n|
      ['Ricky', 'Nigel', 'Chet', 'David', 'Bob', 'Mr.'][n%6]
    end

    sequence :last_name do |n|
      ['Winowiecki', 'Baillie', 'McGillicutty', 'Suckstorff', 'Ross', 'Anderson'][n%6]
    end

    primary_email {|x| x.association(:crm_email) }
    primary_phone {|x| x.association(:crm_phone) }


  end
end

FactoryGirl.define do
  sequence :name do |n|
    ['Test Order', 'Custom Print Order', 'Custom T-shirt Order',
      'Crap Order', 'Expencive Order'][n%5]
  end
  sequence :firstname do |n|
    ['Ricky', 'Nigel', 'Chet', 'David', 'Bob', 'Mr.'][n%6]
  end
  sequence :lastname do |n|
    ['Winowiecki', 'Baillie', 'McGillicutty', 'Suckstorff', 'Ross', 'Anderson'][n%6]
  end
  sequence :email do |n|
    ['test@gmail.com', 'coolguy@example.com', 
     'whatever@umich.edu', 'nice@yahoo.com'].shuffle[n%4]
  end

  factory :order do
    name { generate :name }
    firstname { generate :firstname }
    lastname { generate :lastname }
    email { generate :email }
    twitter '@test'
    po '123 test'
    in_hand_by Time.now + 1.day
    terms "Don't suck"
    tax_exempt false
    needs_redo false
    sales_status :pending
    delivery_method :ship_to_one
    phone_number '123-456-7890'
  end
end
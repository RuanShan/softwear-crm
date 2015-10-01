FactoryGirl.define do
  sequence :name do |n|
    ['Test Order', 'Custom Print Order', 'Custom T-shirt Order',
      'Crap Order', 'Expensive Order'][n%5]
  end

  sequence :firstname do |n|
    ['Ricky', 'Nigel', 'Chet', 'David', 'Bob', 'Mr.'][n%6]
  end

  sequence :lastname do |n|
    ['Winowiecki', 'Baillie', 'McGillicutty', 'Suckstorff', 'Ross', 'Anderson'][n%6]
  end

  factory :blank_order, class: Order do

    factory :order do
      name { generate :name }
      firstname { generate :firstname }
      lastname { generate :lastname }
      sequence(:email) { |n| "order_email_#{n}@gmail.com" }
      twitter '@test'
      in_hand_by Time.now + 1.day
      terms "Half down on purchase"
      tax_exempt false
      delivery_method 'Ship to one location'
      phone_number '123-456-7890'

      before(:create) do |order|
        store = FactoryGirl.create(:valid_store)
        user = FactoryGirl.create(:user, email: "order_#{Random.rand}_guy@gmail.com")
        order.store_id = store.id
        order.salesperson_id = user.id
      end

      factory :order_with_job do
        after(:create) { |o| o.jobs << create(:job) }
        factory :order_with_proofs do
          after(:create) { |o| o.proofs << create(:valid_proof) }
        end
      end
    end
  end
end

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
    subtotal 0
    taxable_total 0
    discount_total 0
    payment_total 0

    factory :order do
      name { generate :name }
      contact { |c| c.association(:crm_contact) }
      in_hand_by Time.now + 1.day
      terms "Half down on purchase"
      tax_exempt false
      delivery_method 'Ship to one location'
      salesperson { |t| t.association(:user, email: "order_#{Random.rand}_guy@gmail.com")} 
      store { |t| t.association(:valid_store) }
      subtotal 0
      taxable_total 0
      discount_total 0
      payment_total 0

      factory :order_with_job do
        after(:create) { |o| o.jobs << create(:job) }
        factory :order_with_proofs do
          after(:create) { |o| o.proofs << create(:valid_proof) }
        end
      end

      factory :fba_order do
        contact nil
        terms "Fulfilled by Amazon"
      end
    end

    factory :deprecated_order do
      contact nil
      name { generate :name }
      deprecated_firstname { generate :firstname }
      deprecated_lastname { generate :lastname }
      sequence(:deprecated_email) { |n| "order_email_#{n}@gmail.com" }
      deprecated_twitter '@test'
      in_hand_by Time.now + 1.day
      terms "Half down on purchase"
      tax_exempt false
      delivery_method 'Ship to one location'
      deprecated_phone_number '123-456-7890'
      salesperson { |t| t.association(:user, email: "order_#{Random.rand}_guy@gmail.com")} 
      store { |t| t.association(:valid_store) }
      subtotal 0
      taxable_total 0
      discount_total 0
      payment_total 0

      factory :deprecated_order_with_job do
        after(:create) { |o| o.jobs << create(:job) }
        factory :deprecated_order_with_proofs do
          after(:create) { |o| o.proofs << create(:valid_proof) }
        end
      end
    end
  end
end

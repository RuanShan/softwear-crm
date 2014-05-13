FactoryGirl.define do
  factory :empty_order, class: 'Order' do
    factory :order do
      name 'Test Order'
      firstname 'Test'
      lastname 'Johnson'
      email 'testj@example.com'
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
end
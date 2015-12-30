FactoryGirl.define do
  factory :blank_payment, class: Payment do

    factory :valid_payment do
      order { |o| o.association(:order) }
      store { |s| s.association(:valid_store) }
      amount '0.00'
      payment_method Payment::VALID_PAYMENT_METHODS.key('Cash')
      salesperson { |p| p.association(:user) }

      factory :cash_payment do

      end

      factory :swiped_credit_card_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('Swiped Credit Card')
      end

      factory :credit_card_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('Credit Card')
        cc_number 'xxxx xxxx xxxx 1111'
        cc_name 'Dwayne Johnson'
        cc_company 'Easy'
        cc_transaction 'asdfjfawjawe'

        before(:create) do |payment|
          def payment.purchase!
            true
          end
        end
      end

      factory :check_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('Check')
        check_dl_no 'w123 456 789'
        check_phone_no '800-555-1212'
      end

      factory :paypal_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('PayPal')
        pp_transaction_id '123456789'
      end

      factory :trade_first_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('Trade First')
        t_name 'Trading Homie Name'
        t_company_name 'Trading Homies'
        tf_number '123456'
      end

      factory :trade_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('Trade')
        t_name 'Trading Homie Name'
        t_company_name 'Trading Homies'
        t_description 'Guns for Butter'
      end

      factory :wire_transfer_payment do
        payment_method Payment::VALID_PAYMENT_METHODS.key('Wire Transfer')
        pp_transaction_id '123456789'
      end
    end
  end
end

require 'spec_helper'
include ApplicationHelper

feature 'Payments management', js: true, payment_spec: true, retry: 2 do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:order) { create(:order) }
  given!(:payment) { create(:valid_payment, order_id: order.id) }
  given(:cc_payment) { create(:credit_card_payment, amount: 10, order_id: order.id) }

  background do
    allow_any_instance_of(Order).to receive(:balance_excluding).and_return 1000
  end

  # No ci because interacting with the dashboard appears to not work there.
  scenario 'A salesperson can visit the payments tab from root', no_ci: true do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    click_link 'List'
    find(:css, "tr#order_#{order.id} td div.btn-group-xs a[data-action='edit']").click
    find(:css, "a[href='#payments']").click
    wait_for_ajax
    expect(current_url).to match((edit_order_path order.id) + '#payments')
  end

  scenario 'A salesperson can toggle a payment type', story_274: true do
    visit edit_order_path order, anchor: 'payments'
    find('#cash-button').click
    sleep 1
    expect(page).to have_css '#payment_amount'
    sleep 1
    find('#cash-button').click
    sleep 1
    expect(page).to_not have_css '#payment_amount'
  end

  scenario 'A salesperson can uncollapse a payment type, then switch to another one', story_274: true do
    visit edit_order_path order, anchor: 'payments'
    find('#cash-button').click
    sleep 1
    expect(page).to have_css '#payment_amount'
    sleep 1
    find('#cc-button').click
    sleep 1.5
  end

  scenario 'A salesperson can make a payment', retry: 3, story_692: true do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '#cash-button').click
    fill_in 'payment_amount', with: '100'
    click_button 'Apply Payment'
    sleep 2
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content 'Payment was successfully created.'
    expect(Payment.find(2)).to be_truthy
  end

  scenario 'A salesperson can make a credit card payment', actual_payment: true do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '#cc-button').click

    fill_in 'payment_amount', with: '100'
    fill_in 'Name on Card', with: 'TEST GUY'
    fill_in 'Company', with: 'aatc'
    # Spaces in the card number should be automatically inserted
    fill_in 'Card Number', with: '4111111111111111'
    # The slash in expiration date should be automatically inserted
    fill_in 'Expiration', with: '1229'
    fill_in 'CVC', with: '123'

    click_button 'Apply Payment'
    sleep 2
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content 'Payment was successfully created.'
    expect(Payment.find(2)).to be_truthy
  end

  scenario 'A salesperson can partially refund a credit card payment', actual_payment: true do
    payment.destroy
    cc_payment.update_column :amount, '10.00'
    cc_payment.update_column :cc_transaction, nil

    visit (edit_order_path order.id) + '#payments'
    find(:css, '.order_payment_refund_link').click

    sleep 3

    fill_in 'Reason', with: 'have some money'
    fill_in 'Amount', with: '5.00'
    sleep 2

    click_button 'Apply Discount'

    expect(page).to have_content 'Successfully created refund. No cards were credited.'
    expect(page).to have_content '$10.00 - $5.00'

    expect(Payment.find(cc_payment.id).is_refunded?).to eq true
  end

  scenario 'A salesperson cannot refund more than the payment amount', actual_payment: true do
    payment.destroy
    cc_payment.update_column :amount, '10.00'
    cc_payment.update_column :cc_transaction, nil

    visit (edit_order_path order.id) + '#payments'
    find(:css, '.order_payment_refund_link').click

    sleep 3

    fill_in 'Reason', with: 'have some money'
    fill_in 'Amount', with: '15.00'
    sleep 2

    click_button 'Apply Discount'

    expect(page).to have_content 'Amount exceeds the payment amount'
    expect(page).to_not have_content '$10.00 - $5.00'

    expect(Payment.find(cc_payment.id).is_refunded?).to eq false
  end

  scenario 'A salesperson can refund an entire payment', huh: true, retry: 2, actual_payment: true do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '.order_payment_refund_link').click

    sleep 3

    fill_in 'Reason', with: "Gaga can't handle this shit"
    click_button 'Apply Discount'

    sleep 2

    expect(page).to have_content 'Successfully created refund. No cards were credited.'
    expect(Payment.find(payment.id).is_refunded?).to be_truthy
  end

  context 'when payflow credentials are set up', payflow: true do
    given(:gateway) { double('activemerchant gateway') }

    background do
      allow(Setting).to receive(:payflow_login).and_return 'ok'
      allow(Setting).to receive(:payflow_password).and_return 'yeafhweawefawe'
      allow_any_instance_of(Payment).to receive(:gateway).and_return gateway
      allow_any_instance_of(Discount).to receive(:discountable).and_return cc_payment

      payment.destroy
      cc_payment.update_column :amount, '10.00'
      cc_payment.update_column :cc_transaction, 'abc123'
    end

    scenario "A salesperson refunding a payment credits the payment's card", actual_payment: true do
      expect(gateway).to receive(:refund).with(500, 'abc123', anything)
        .and_return double('success', success?: true)

      visit (edit_order_path order.id) + '#payments'
      find(:css, '.order_payment_refund_link').click

      sleep 3

      fill_in 'Reason', with: 'have some money'
      fill_in 'Amount', with: '5.00'
      sleep 2

      click_button 'Apply Discount'

      expect(page).to have_content "Refund successful! Customer's card"
      expect(page).to have_content "was credited"
      expect(page).to have_content '$10.00 - $5.00'

      expect(Payment.find(cc_payment.id).is_refunded?).to eq true
    end

    scenario 'An error when processing the refund results in an error message and no refund created' do
      expect(gateway).to receive(:refund).with(500, 'abc123', anything)
        .and_return double('failure', success?: false, message: 'banned!!!')

      visit (edit_order_path order.id) + '#payments'
      find(:css, '.order_payment_refund_link').click

      sleep 3

      fill_in 'Reason', with: 'have some money'
      fill_in 'Amount', with: '5.00'
      sleep 2

      click_button 'Apply Discount'

      expect(page).to have_content "banned!!!"

      expect(Payment.find(cc_payment.id).is_refunded?).to eq false
    end

    scenario "When the #refund! returns false (due to some weird error), refund is still created" do
      expect(gateway).to_not receive(:refund)
      expect(cc_payment).to receive(:refund!).and_return false

      visit (edit_order_path order.id) + '#payments'
      find(:css, '.order_payment_refund_link').click

      sleep 3

      fill_in 'Reason', with: 'have some money'
      fill_in 'Amount', with: '5.00'
      sleep 2

      click_button 'Apply Discount'

      expect(page).to have_content "Refund noted, but was UNABLE to add funds to the card."

      expect(Payment.find(cc_payment.id).is_refunded?).to eq true
    end
  end

  feature 'the following activities are tracked', public_activity: true do
    scenario 'applying a payment' do
      visit (edit_order_path order.id) + '#payments'
      find(:css, '#cash-button').click
      fill_in 'payment_amount', with: 20
      click_button 'Apply Payment'
      sleep 2
      page.driver.browser.switch_to.alert.accept
      activity = order.all_activities.to_a.select{ |a| a[:key] = 'payment.applied_payment' }
      expect(activity).to_not be_nil
    end

    scenario 'refunding a payment', huh: true, retry: 2 do
      visit (edit_order_path order.id) + '#payments'
      sleep 0.5
      find(:css, '.order_payment_refund_link').click
      sleep 3
      fill_in 'Reason', with: 'Muh spoon is too big'
      click_button 'Apply Discount'
      sleep 2
      activity = order.all_activities.to_a.select{ |a| a[:key] = 'payment.refunded_payment' }
      expect(activity).to_not be_nil
    end
  end
end

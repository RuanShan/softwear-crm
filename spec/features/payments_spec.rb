require 'spec_helper'
include ApplicationHelper

feature 'Payments management', js: true, payment_spec: true, retry: 2 do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:order) { create(:order) }
  given!(:payment) { create(:valid_payment, order_id: order.id) }

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

  context 'with a refunded payment' do
    scenario 'balance is still correctly computed and displayed', story_692: true do
      visit (edit_order_path order.id) + '#payments'
      find(:css, '#cash-button').click
      fill_in 'amount_field', with: '20'
      click_button 'Apply Payment'
      sleep 2
      page.driver.browser.switch_to.alert.accept
      close_flash_modal
      find(:css, "a.order_payment_refund_link[href='/payments/#{payment.id}/edit?order_id=#{order.id}&refund=true']").click
      fill_in 'Refund Reason', with: 'how do i money?'
      click_button 'Refund Payment'
      sleep 2
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content 'Payment was successfully updated.'
      expect(Payment.find(payment.id).is_refunded?).to be_truthy
    end
  end

  scenario 'A salesperson can toggle a payment type', story_274: true do
    visit edit_order_path order, anchor: 'payments'
    find('#cash-button').click
    sleep 1
    expect(page).to have_css '#amount_field'
    sleep 1
    find('#cash-button').click
    sleep 1
    expect(page).to_not have_css '#amount_field'
  end

  scenario 'A salesperson can uncollapse a payment type, then switch to another one', story_274: true do
    visit edit_order_path order, anchor: 'payments'
    find('#cash-button').click
    sleep 1
    expect(page).to have_css '#amount_field'
    expect(page).to_not have_css '#payment_cc_batch_no'
    sleep 1
    find('#cc-button').click
    sleep 1.5
    expect(page).to have_css '#payment_cc_batch_no'
  end

  scenario 'A salesperson can make a payment', retry: 3, story_692: true do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '#cash-button').click
    fill_in 'amount_field', with: '100'
    click_button 'Apply Payment'
    sleep 2
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content 'Payment was successfully created.'
    expect(Payment.find(2)).to be_truthy
  end

  scenario 'A salesperson can refund a payment', retry: 2, story_692: true do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '.order_payment_refund_link').click
    fill_in 'Refund Reason', with: 'Gaga can\'t handle this shit'
    click_button 'Refund Payment'
    sleep 2 
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content 'Payment was successfully updated.'
    expect(Payment.find(payment.id).is_refunded?).to be_truthy
  end

  feature 'the following activities are tracked' do
    scenario 'applying a payment' do
      visit (edit_order_path order.id) + '#payments'
      find(:css, '#cash-button').click
      fill_in 'amount_field', with: 20
      click_button 'Apply Payment'
      sleep 2
      page.driver.browser.switch_to.alert.accept
      activity = order.all_activities.to_a.select{ |a| a[:key] = 'payment.applied_payment' }
      expect(activity).to_not be_nil
    end

    scenario 'refunding a payment', retry: 2 do
      visit (edit_order_path order.id) + '#payments'
      sleep 0.5
      find(:css, '.order_payment_refund_link').click
      fill_in 'Refund Reason', with: 'Muh spoon is too big'
      click_button 'Refund Payment'
      sleep 2
      page.driver.browser.switch_to.alert.accept
      activity = order.all_activities.to_a.select{ |a| a[:key] = 'payment.refunded_payment' }
      expect(activity).to_not be_nil
    end
  end
end

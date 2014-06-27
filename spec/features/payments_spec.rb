require 'spec_helper'
include ApplicationHelper

feature 'Payments management', js: true, payment_spec: true do

  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  given!(:order) { create(:order) }
  given!(:payment) { create(:valid_payment, order_id: order.id) }

  scenario 'A salesperson can visit the payments tab from root' do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    click_link 'List'
    find(:css, "tr#order_#{order.id} td div.btn-group-xs a[data-action='edit']").click
    find(:css, "a[href='#payments']").click
    wait_for_ajax
    expect(current_url).to match((edit_order_path order.id) + '#payments')
  end

  scenario 'A salesperson can make a payment' do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '#cash-button').click
    fill_in 'amount_field', with: '100'
    click_button 'Apply Payment'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_selector '.modal-content-success', text: 'Payment was successfully created.'
    expect(Payment.find(2)).to be_truthy
  end

  scenario 'A salesperson can refund a payment' do
    visit (edit_order_path order.id) + '#payments'
    find(:css, '.order_payment_refund_link').click
    fill_in 'payment_refund_reason', with: 'check bounced!!!! lololol'
    click_button 'Refund Payment'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_selector '.modal-content-success', text: 'Payment was successfully updated.'
    expect(Payment.find(payment.id).is_refunded?).to be_truthy
  end
end

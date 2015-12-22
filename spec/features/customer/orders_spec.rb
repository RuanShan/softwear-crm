require 'spec_helper'
include ApplicationHelper

feature 'Customer Order Management', customer: true, order_spec: true, js: true do

  given!(:order) { create(:order) }

  scenario 'A customer provided the link to the order can view the order' do
    visit customer_order_path(order.customer_key)
    expect(page).to have_text("Invoice ##{order.id}")
  end

  scenario 'A customer can approve the invoice' do
    visit customer_order_path(order.customer_key)

    toggle_dashboard
    click_link 'Approve/Reject Invoice'
    sleep 1
    find('input[value=approved').click
    click_button 'Submit'

    expect(page).to have_content 'We have been informed of your approval'
    expect(page).to have_content 'Thanks'

    expect(order.reload.invoice_state).to eq 'approved'

    expect(page).to_not have_content 'Approve/Reject Invoice'
  end

  scenario 'A customer can reject the invoice' do
    visit customer_order_path(order.customer_key)

    toggle_dashboard
    click_link 'Approve/Reject Invoice'
    sleep 1
    find('input[value=rejected').click
    find('textarea').set 'psyche'
    click_button 'Submit'

    expect(page).to have_content 'Thanks for your feedback'

    expect(order.reload.invoice_state).to eq 'rejected'

    expect(page).to_not have_content 'Approve/Reject Invoice'
  end

  scenario 'A customer cannot reject the invoice without a reason' do
    visit customer_order_path(order.customer_key)

    toggle_dashboard
    click_link 'Approve/Reject Invoice'
    sleep 1
    find('input[value=rejected').click
    click_button 'Submit'

    expect(page).to have_content "can't be blank"

    expect(order.reload.invoice_state).to_not eq 'rejected'
  end

  # Payment specs are in spec/features/payments_spec.rb
end

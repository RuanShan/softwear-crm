require 'spec_helper'
include ApplicationHelper

feature 'Payments management', payment_spec: true do

  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  given!(:order) { create(:order) }


  scenario 'A salesperson can make a payment', new: true do
    visit orders_path
    find("tr#order_#{order.id} a[data-action='edit']").click
    # click payments tab by xpath
    find(:xpath, "/html/body/div[2]/div[3]/div[2]/div[2]/div/div/ul/li[4]/a").click
    find(:css, '#apply_cash').click
    fill_in 'Amount', with: '100.00'
    click_button 'Submit'
    click_button 'Confirm'
    expect(page).to have_selector '.modal-content-success', text: 'Payment was successfully applied.'
    expect(PaymentMethod.find(1)).to be_truthy
  end

  scenario 'A salesperson can refund a payment'
end

require 'spec_helper'

feature 'Discounts management', js: true, discount_spec: true, story_859: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:order) { create(:order) }

  scenario 'A salesperson can add a "refund" discount' do
    visit edit_order_path order, anchor: 'payments'
    click_button 'Refund'

    fill_in 'Amount', with: '12.50'
    fill_in 'Reason', with: 'Because I can'
    select 'PayPal', from: 'Discount method'
    fill_in 'Transaction ID', with: '123123123'

    click_button 'Apply Discount'

    expect(page).to have_content 'Discount was successfully created.'
    expect(Discount.where(amount: 12.5, reason: 'Because I can', discount_method: 'PayPal', transaction_id: '123123123')).to exist
  end

  scenario 'A salesperson can add a "coupon" discount' do
    visit edit_order_path order, anchor: 'payments'
    click_button 'Refund'

    expect(true).to eq false# TODO ...
  end
end

require 'spec_helper'

feature 'Discounts management', js: true, discount_spec: true, story_859: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  given!(:order) { create(:order) }
  given(:coupon) { create(:flat_rate) }

  context 'refunds' do
    scenario 'A salesperson can add a "refund" discount' do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Refund'

      fill_in 'Amount', with: '12.50'
      fill_in 'Reason', with: 'Because I can'
      select 'Cash', from: 'Discount method'
      fill_in 'Transaction ID', with: '123123123'

      click_button 'Apply Discount'

      expect(page).to have_content 'Discount was successfully created.'
      expect(Discount.where(amount: 12.5, reason: 'Because I can', discount_method: 'Cash', transaction_id: '123123123')).to exist
    end
  end

  context 'coupons' do
    scenario 'A salesperson can add a "coupon" discount' do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Coupon'

      select 'Cash', from: 'Discount method'
      fill_in 'Coupon code', with: coupon.code

      click_button 'Apply Discount'

      expect(page).to have_content 'Discount was successfully created.'
      expect(Discount.where(discount_method: 'Cash', applicator_type: 'Coupon', applicator_id: coupon.id)).to exist
    end

    scenario 'A salesperson sees an error when entering a bad coupon code' do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Coupon'

      select 'Cash', from: 'Discount method'
      fill_in 'Coupon code', with: 'notarealcouponcode'

      click_button 'Apply Discount'

      expect(page).to have_content 'Coupon code does not corrospond to any coupon in the system'
      expect(page).to_not have_content 'Reason'
    end
  end
end

require 'spec_helper'

feature 'Discounts management', js: true, discount_spec: true, story_859: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { sign_in_as(valid_user) }

  given!(:order) { create(:order_with_job) }
  given(:job) { order.jobs.first }
  given(:coupon) { create(:flat_rate) }
  given(:percent_off_job) { create(:percent_off_job) }
  given(:fifty_percent_off_order) { create(:percent_off_order, value: 50) }

  given(:credit_1) { create(:in_store_credit) }
  given(:credit_2) { create(:in_store_credit) }

  context 'refunds' do
    background do
      create(:non_imprintable_line_item, unit_price: 100.00, quantity: 1, taxable: false, line_itemable: order.jobs.first)
      create(:cash_payment, amount: 10, order: order.reload)
    end

    scenario 'A salesperson cannot add a "refund" discount to an order payment', refund: true do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Refund'

      select order.payments.first.identifier, from: 'Payment'
      fill_in 'Amount', with: '5.00'
      fill_in 'Reason', with: 'Because I can'

      click_button 'Issue Refund'

      expect(page).to have_content 'Successfully created'
      expect(Discount.where(amount: 5, reason: 'Because I can', discount_method: 'RefundPayment')).to exist
    end
  end

  context 'discounts' do
    scenario 'A salesperson can add a "discount" discount' do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Discount'

      fill_in 'Amount', with: '12.50'
      fill_in 'Reason', with: 'Because I can'

      click_button 'Apply Discount'

      expect(page).to have_content 'was successfully created.'
      expect(Discount.where(amount: 12.5, reason: 'Because I can')).to exist
    end

    scenario 'Adding a "discount" discount is tracked', public_activity: true do
      PublicActivity.with_tracking do
        visit edit_order_path order, anchor: 'payments'
        click_button 'Discount'

        fill_in 'Amount', with: '12.50'
        fill_in 'Reason', with: 'Because I can'

        click_button 'Apply Discount'

        expect(page).to have_content 'was successfully created.'

        visit edit_order_path order
        find('a[href="#timeline"]').click

        expect(page).to have_content 'Applied discount'
        expect(page).to have_content 'of $12.50 to the order "'
        expect(page).to have_content 'bringing the total from $0.00 to -$12.50'
        expect(page).to have_content 'Reason: "Because I can"'
      end
    end
  end

  context 'coupons' do
    scenario 'A salesperson can add a "coupon" discount' do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Coupon'

      fill_in 'Coupon code', with: coupon.code

      click_button 'Apply Discount'

      expect(page).to have_content 'was successfully created.'
      expect(Discount.where(applicator_type: 'Coupon', applicator_id: coupon.id)).to exist
    end

    scenario 'An existing coupon updates its amount when the order subtotal is changed', recalculating: true, story_1124: true do
      order.tax_exempt = true
      order.jobs.first.line_items << create(:non_imprintable_line_item, unit_price: 100.00, quantity: 1, taxable: false)
      order.save!
      expect(order.reload.balance).to eq 100
      create(:discount, applicator: fifty_percent_off_order, discountable: order)
      expect(order.reload.balance).to eq 50
      visit edit_order_path order

      find('.line-item-button[title="Edit"]').click
      sleep 0.5
      fill_in "line_item[#{order.jobs.first.line_items.first.id}[unit_price]]", with: '50.00'
      find('.update-line-items').click
      wait_for_ajax
      visit edit_order_path order
      find('a[href="#payments"]').click

      expect(order.reload.balance).to eq 25
      expect(page).to have_content "25.0 Balance"
    end

    scenario 'Removing a coupon is tracked', public_activity: true, remove: true do
      PublicActivity.with_tracking do
        order.tax_exempt = true
        order.jobs.first.line_items << create(:non_imprintable_line_item, unit_price: 100.00, quantity: 1, taxable: false)
        order.save!
        expect(order.reload.balance).to eq 100
        create(:discount, applicator: fifty_percent_off_order, discountable: order)
        expect(order.reload.balance).to eq 50

        visit edit_order_path order, anchor: 'payments'

        click_link 'Remove'

        visit edit_order_path order
        find('a[href="#timeline"]').click

        expect(page).to have_content "Removed coupon of $50.00"
        expect(page).to have_content "bringing its balance from $50.00 to $100.00"
      end
    end

    scenario 'A salesperson sees an error when entering a bad coupon code' do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Coupon'

      fill_in 'Coupon code', with: 'notarealcouponcode'

      click_button 'Apply Discount'

      expect(page).to have_content 'Coupon code does not correspond to any coupon in the system'
      expect(page).to_not have_content 'Reason'
    end

    scenario 'A salesperson can add a percent-off-job coupon discount', retry: 3 do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Coupon'

      fill_in 'Coupon code', with: percent_off_job.code
      sleep 1
      find('#discount_discountable_id_select').select job.name

      click_button 'Apply Discount'

      expect(page).to have_content 'was successfully created.'
      expect(Discount.where(applicator_type: 'Coupon', applicator_id: percent_off_job.id)).to exist
      expect(Discount.where(applicator_type: 'Coupon', applicator_id: percent_off_job.id).first.discountable).to eq job
    end
  end

  context 'in-store credit' do
    background do
      allow(InStoreCredit).to receive(:search)
        .and_return double('Search Results', results: [credit_1, credit_2])
    end

    scenario 'A salesperson can add an "in-store credit" discount', isc: true do
      visit edit_order_path order, anchor: 'payments'
      click_button 'Apply In-Store Credit'

      find('.in-store-credit-search').set('search terms')
      click_button 'Search'

      expect(page).to have_content credit_1.name
      expect(page).to have_content credit_1.customer_name
      expect(page).to have_content credit_1.customer_email

      first('input[type=checkbox]').set true
      click_button 'Add Selected'

      expect(page).to have_content credit_1.name
      expect(page).to have_content credit_1.customer_name
      expect(page).to have_content credit_1.customer_email

      click_button 'Apply Discount'

      expect(page).to have_content "Successfully added 1 in-store credit discount"

      expect(order.reload.discounts.size).to eq 1
      expect(order.discounts.first.applicator).to eq credit_1
    end
  end
end

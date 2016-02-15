require 'spec_helper'
include ApplicationHelper

feature 'Coupons management', story_857: true do
  given!(:valid_user) { create(:user) }
  before(:each) do
    sign_in_as(valid_user)
  end

  let!(:coupon) { create(:flat_rate) }

  scenario 'User views list of existing coupons' do
    visit root_path
    click_link 'Administration'
    click_link 'Coupons'
    expect(page).to have_css("tr##{model_table_row_id(coupon)}")
  end

  scenario 'User creates a new coupon' do
    visit coupons_path
    click_link 'Add a Coupon'
    fill_in 'Name', with: 'Test Coupon'
    fill_in 'Valid from', with: 2.days.ago.strftime('%b %d, %Y, %I:%M %p')
    fill_in 'Valid until', with: 2.days.from_now.strftime('%b %d, %Y, %I:%M %p')
    find('#coupon_calculator').select 'Percent off order'
    fill_in 'Value', with: '50'
    click_button 'Create Coupon'

    expect(Coupon.where(name: 'Test Coupon', calculator: 'percent_off_order', value: 50)).to exist
    expect(page).to have_selector('#flash_notice', text: 'Coupon was successfully created.')
  end

  scenario 'User deletes an existing coupon', js: true, story_692: true do
    visit coupons_path
    find("tr#coupon_#{coupon.id} a[data-action='destroy']").click
    sleep 2 if ci?
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(Coupon.where(id: coupon.id)).to_not exist
  end

  scenario 'User edits an existing coupon' do
    visit coupons_path
    find("tr#coupon_#{coupon.id} a[data-action='edit']").click
    fill_in 'Name', with: 'Edited Coupon Name'
    click_button 'Update Coupon'
    expect(coupon.reload.name).to eq('Edited Coupon Name')
    expect(page).to have_selector('#flash_notice', text: 'Coupon was successfully updated.')
  end
end

require 'spec_helper'
include ApplicationHelper

feature 'Shipping Methods management' do

  let!(:shipping_method) { create(:valid_shipping_method)}

  scenario 'User views list of existing shipping methods' do
    visit root_path
    click_link 'Shipping Methods'
    expect(page).to have_css("tr##{model_table_row_id(shipping_method)}")
  end

  scenario 'User creates a new shipping method' do
    visit shipping_methods_path
    click_link 'Add a Shipping Method'
    fill_in 'Name', with: 'New Shipping Method'
    fill_in 'Tracking url', with: 'http://www.tracking-url.com'
    click_button 'Create Shipping Method'
    expect(ShippingMethod.where(name: 'New Shipping Method')).to exist
    expect(page).to have_selector('#flash_notice', text: 'Shipping method was successfully created.')
  end

  scenario 'User deletes an existing shipping method', js: true do
    visit shipping_methods_path
    find("tr#shipping_method_#{shipping_method.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect( shipping_method.reload.destroyed? ).to be_truthy
  end

  scenario 'User edits an existing shipping method' do
    visit shipping_methods_path
    find("tr#shipping_method_#{shipping_method.id} a[data-action='edit']").click
    fill_in 'Name', with: 'Edited Shipping Method Name'
    click_button 'Update Shipping Method'
    expect(shipping_method.reload.name).to eq('Edited Shipping Method Name')
    expect(page).to have_selector('#flash_notice', text: 'Shipping method was successfully updated.')
  end

end
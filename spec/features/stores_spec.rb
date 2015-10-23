require 'spec_helper'
include ApplicationHelper

feature 'Stores management', store_spec: true do
  given!(:valid_user) { create(:user) }
  given!(:store) { create(:valid_store) }

  background(:each) { login_as(valid_user) }

  scenario 'User views list of existing stores' do
    visit root_path
    click_link 'Stores'
    expect(page).to have_css("tr##{model_table_row_id(store)}")
  end

  scenario 'User creates a new store' do
    visit stores_path
    click_link 'show_new_link'
    fill_in 'Name', with: 'New Store'
    fill_in 'Address 1', with: 'Address 1'
    fill_in 'Address 2', with: 'Address 2'
    fill_in 'City', with: 'City'
    fill_in 'State', with: 'State'
    fill_in 'Zipcode', with: 'Zipcode'
    fill_in 'Country', with: 'United States'
    fill_in 'Phone', with: '800-555-1212'
    fill_in 'Sales email', with: 'sales@softwearcrm.com'
    click_button 'Create Store'
    expect(page).to have_selector('#flash_notice', text: 'Store was successfully created.')
    expect(page).to have_selector('.store-address', text: 'Address 1')
    expect(page).to have_selector('.store-address', text: 'Address 2')
    expect(page).to have_selector('.store-address', text: 'City')
    expect(page).to have_selector('.store-address', text: 'State')
    expect(page).to have_selector('.store-address', text: 'Zipcode')
    expect(page).to have_selector('.store-address', text: 'United States')
    expect(page).to have_selector('.store-address', text: '800-555-1212')
    expect(page).to have_selector('.store-address', text: 'sales@softwearcrm.com')
  end

  scenario 'User deletes an existing store', js: true, story_692: true do
    visit stores_path
    find("tr#store_#{store.id} a[data-action='destroy']").click
    sleep 2 if ci?
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(store.reload.deleted_at).not_to eq(nil)
  end

  scenario 'User edits an existing store' do
    visit stores_path
    find("tr#store_#{store.id} a[data-action='edit']").click
    fill_in 'Name', with: 'Edited Store Name'
    click_button 'Update Store'
    expect(store.reload.name).to eq('Edited Store Name')
    expect(page).to have_selector('#flash_notice', text: 'Store was successfully updated.')
  end
end

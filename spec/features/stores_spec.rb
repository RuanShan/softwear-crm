require 'spec_helper'
include ApplicationHelper

feature 'Stores management', store_spec: true do
  given!(:valid_user) { create(:user) }
  given!(:store) { create(:valid_store)}

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
    click_button 'Create Store'
    expect(Store.where(name: 'New Store')).to exist
    expect(page).to have_selector('#flash_notice', text: 'Store was successfully created.')
  end

  scenario 'User deletes an existing store', js: true do
    visit stores_path
    find("tr#store_#{store.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(store.reload.destroyed?).to be_truthy
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
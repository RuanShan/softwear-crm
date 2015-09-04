require 'spec_helper'
include ApplicationHelper

feature 'In-Store Credit management', story_858: true do
  given!(:valid_user) { create(:user) }
  before(:each) do
    login_as(valid_user)
  end

  let!(:in_store_credit) { create(:in_store_credit) }

  scenario 'User views list of existing in_store_credits' do
    visit root_path
    click_link 'Administration'
    click_link 'In-Store Credit'
    expect(page).to have_css("tr##{model_table_row_id(in_store_credit)}")
  end

  scenario 'User creates a new in-store credit' do
    visit in_store_credits_path
    click_link 'Add In-Store Credit'
    fill_in 'Name', with: 'New Credit'
    fill_in 'Customer first name', with: 'Big'
    fill_in 'Customer last name', with: 'Daddy'
    fill_in 'Customer email', with: 'bd@gmail.com'
    fill_in 'Description', with: 'you know how it goes'
    fill_in 'Valid until', with: 2.days.from_now.strftime('%b %d, %Y, %I:%M %p')
    fill_in 'Amount', with: '25'

    click_button 'Create In-Store Credit'

    expect(
      InStoreCredit.where(
        name: 'New Credit', customer_first_name: 'Big', customer_last_name: 'Daddy',
        customer_email: 'bd@gmail.com', description: 'you know how it goes',
        amount: 25
      )
    ).to exist

    sleep 0.1
    expect(page).to have_selector('#flash_notice', text: 'In store credit was successfully created.')
  end

  scenario 'User deletes an existing in_store_credit', js: true do
    visit in_store_credits_path
    find("tr#in_store_credit_#{in_store_credit.id} a[data-action='destroy']").click
    sleep 2 if ci?
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(InStoreCredit.where(id: in_store_credit.id)).to_not exist
  end

  scenario 'User edits an existing in_store_credit' do
    visit in_store_credits_path
    find("tr#in_store_credit_#{in_store_credit.id} a[data-action='edit']").click
    fill_in 'Name', with: 'Edited ISC Name'
    click_button 'Update In-Store Credit'
    expect(in_store_credit.reload.name).to eq('Edited ISC Name')
    sleep 0.1
    expect(page).to have_selector('#flash_notice', text: 'In store credit was successfully updated.')
  end
end

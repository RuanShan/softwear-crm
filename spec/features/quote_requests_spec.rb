require 'spec_helper'
include ApplicationHelper

feature 'Quote Request Features', js: true, quote_request_spec: true, story_79: true do
  given!(:quote_request) { create(:quote_request) }
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  scenario 'A user can create a Quote from a Quote Request' do
    visit root_path
    unhide_dashboard
    click_link 'Quotes'
    click_link 'Quote Requests'
    click_link 'Generate Quote'

    expect(page).to have_css("#quote_email[value='#{quote_request.email}']")

    click_button 'Next'
    sleep 0.5

    fill_in 'Quote Name', with: 'Quote Name'
    find('#quote_quote_source').find("option[value='Other']").click
    sleep 1
    fill_in 'Valid Until Date', with: Time.now + 1.day
    fill_in 'Estimated Delivery Date', with: Time.now + 1.day
    click_button 'Next'
    sleep 0.5

    fill_in 'line_item_group_name', with: 'Sweet as hell line items'
    click_link 'Add Line Item'
    fill_in 'Name', with: 'Line Item Name'
    fill_in 'Description', with: 'Line Item Description'
    fill_in 'Quantity', with: 2
    fill_in 'Unit Price', with: 15
    click_button 'Submit'

    wait_for_ajax
    expect(page).to have_selector '.modal-content-success', text: 'Quote was successfully created.'
    expect(current_path). to eq(quote_path(quote.id + 1))
    expect(Quote.where(quote_request_ids: [quote_request.id])).to exist
  end
end
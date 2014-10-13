require 'spec_helper'
include ApplicationHelper

feature 'Quote Requests Management', js: true, quote_request_spec: true do
  given!(:quote_request) { create(:valid_quote_request_with_salesperson) }
  given!(:valid_user) { create(:alternate_user) }
  before(:each) { login_as(valid_user) }

  scenario 'A user can view a list of quote requests' do
    visit root_path
    unhide_dashboard
    click_link 'quotes_list'
    click_link 'quote_requests_link'
    sleep 10
    expect(page).to have_selector('.box-info')
    expect(current_path).to eq(quote_requests_path)
  end

  scenario 'A user can change the assignment of a quote request', story_80: true do
    visit quote_requests_path
    page.find('span.editable').click
    page.find('div.editable-input').find("option[value='#{valid_user.id}']").click
    page.find('button.editable-submit').click
    expect(QuoteRequest.where(salesperson_id: valid_user.id)).to exist
  end

  scenario 'A user can assign an unassigned quote request', story_80: true do
    quote_request.salesperson_id = nil
    quote_request.save
    visit quote_requests_path
    page.find('span.editable').click
    page.find('div.editable-input').find("option[value='#{valid_user.id}']").click
    page.find('button.editable-submit').click
    expect(QuoteRequest.where(salesperson_id: valid_user.id)).to exist
  end
end

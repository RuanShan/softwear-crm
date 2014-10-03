require 'spec_helper'
include ApplicationHelper

feature 'Quote Requests Management', js: true, quote_request_spec: true do
  given!(:quote_request) { create(:valid_quote_request) }
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

  # scenario 'A user can assign an unassigned quote request' do
  #   visit quote_requests_path
  #   page.find("TABLE CELL THAT HOLDS UNASSIGNED VALUE FOR SALESPERSON")
  #   page.click("ASSIGN")
  #   page.click("SELECT BOX WITH SALESPERSON")
  #   page.click("A SALESPERSON VALUE FROM THE SELECT BOX")
  #   page.click("ASSIGN BUTTON THAT SUBMITS THIS CHANGE")
  #   expect(page).to have_css("for the persons's name that shows up now")
  #   expect(page).to have_css("for button to change the salesperson")
  #   expect(QuoteRequest.where(salesperson: "WHATEVER WE CHOSE")).to_exist
  # end
  #
  # scenario 'A user can change the assignment of a quote request' do
  #   visit quote_requests_path
  #   page.find("TABLE CELL THAT HOLDS ASSIGNED VALUE FOR SALESPERSON")
  #   page.click("CHANGE")
  #   page.click("SELECT BOX WITH SALESPERSON")
  #   page.click("A SALESPERSON VALUE FROM THE SELECT BOX")
  #   page.click("ASSIGN BUTTON THAT SUBMITS THIS CHANGE")
  #   expect(page).to have_css("for the persons's name that shows up now")
  #   expect(page).to have_css("for button to change the salesperson")
  #   expect(QuoteRequest.where(salesperson: "WHATEVER WE CHOSE")).to_exist
  # end
end

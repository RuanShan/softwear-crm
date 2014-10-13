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
    find("BUTTON TO GENERATE QUOTE").click
    expect(page).to 'BE THE FORM FOR CREATING A QUOTE WITH FIELDS FILLED IN'
  end
end
require 'spec_helper'
include ApplicationHelper
require 'email_spec'

feature 'Sales Reports management', sales_report_spec: true, js: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { sign_in_as(valid_user) }

  given!(:quote) { create(:valid_quote) }
  given!(:imprintable) { create(:valid_imprintable) }

  scenario 'A user can view a sales report', retry: 2, story_82: true do
    visit root_path
    unhide_dashboard
    click_link 'Reports'
    click_link 'Sales Reports'
    #  filling in with blanks is needed because datetime picker will
    #  automatically fill in with the current date on focus
    fill_in 'start_time', with: ''
    fill_in 'start_time', with: '2014-11-10'
    fill_in 'end_time', with: ''
    fill_in 'end_time', with: '2014-11-11'
    sleep 10
    select 'Quote Request Success Report', from: 'report_type'
    click_button 'Run Report'
    expect(page).to have_content('Quote Request Success Report from 2014-11-10 to 2014-11-11')
    expect(page).to have_content('Total Quote Requests Received: 0')
    expect(page).to have_content('Total Quotes from Requests: 0')
    expect(page).to have_content('Total Orders from Requests: 0')
  end
end


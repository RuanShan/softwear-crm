require 'spec_helper'
include ApplicationHelper

feature 'Sales Reports Features', js: true, artwork_request_spec: true do
  background 'An authorized user' do
    given!(:valid_user) { create(:alternate_user) }
    background(:each) { login_as(valid_user) }

    scenario 'Can report on how many quote requests have become orders'
      # Visit app
      # Click reports
      # Click "Sales Reports"
      # Set timeframe, select report, and press "Report"
      # See results of report
  end

end
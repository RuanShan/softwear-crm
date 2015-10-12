require 'spec_helper'
include ApplicationHelper

feature 'Sales Reports Features', js: true, artwork_request_spec: true do
  background 'An authorized user' do
    given!(:valid_user) { create(:alternate_user) }
    background(:each) { login_as(valid_user) }

    scenario 'Can report on how many quote requests have become orders'
    
    scenario 'Can report on the total number of payments taken in a given day', pending: true do 
      visit root_path
      click_link 'Reports'
      click_link 'Sales Report'
      expect(false).to be_truthy
    end
  end

end

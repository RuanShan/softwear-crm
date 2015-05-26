require 'spec_helper'

feature 'FreshdeskTicketViewing' do 
  given!(:valid_user) { create(:alternate_user, insightly_api_key: "insight") }
  background(:each) { login_as(valid_user) }
  
  # Stub a freshdesk response to have freshdesk_ticket['notes']['note']['body_html']
  # allow the quote to receive the freshdesk function call that gives me the thing above, and make it respond with the hash i want

  context 'a quote has a freshdesk ticket, and that ticket has quoted text' do 
   given!(:quote) { create(:valid_quote) }
   
    background(:each) do 
      allow(quote).to receive(:no_ticket_id_entered?).and_return false
      allow(quote).to receive(:no_fd_login?).and_return false
      allow(quote).to receive(:has_freshdesk_ticket?).and_return true
    end

      
    scenario 'A user can toggle quoted freshdesk text', js: true do
      visit edit_quote_path(quote)
      click_link 'Details'
      # make sure quoted text is hidden
      click_link 'Toggle Quoted Text'
     # make sure quoted text is shown
    end
  end

end

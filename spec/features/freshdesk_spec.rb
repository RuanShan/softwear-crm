require 'spec_helper'

feature 'FreshdeskTicketViewing' do 
  given!(:valid_user) { create(:alternate_user, insightly_api_key: "insight") }
  background(:each) { login_as(valid_user) }
  
  # Stub a freshdesk response to have freshdesk_ticket['notes']['note']['body_html']
  # allow the quote to receive the freshdesk function call that gives me the thing above, and make it respond with the hash i want

  context 'a quote has a freshdesk ticket, and that ticket has quoted text' do 
   given!(:quote) { create(:valid_quote) }
   given!(:fd_ticket) do   {
    "created_at" => "Thu, 21 May 2015 15:57:32 EDT -04:00",  
    "notes" => 
    [
      {"note" => {"body_html" => "<p></p><blockquote class=\"freshdesk_quote\">wasabi451</blockquote>", "created_at" => "aba" }} 
    ]
   }
   end
   
    background(:each) do 
      allow_any_instance_of(Quote).to receive(:no_ticket_id_entered?).and_return false
      allow_any_instance_of(Quote).to receive(:no_fd_login?).and_return false
      allow_any_instance_of(Quote).to receive(:has_freshdesk_ticket?).and_return true
      allow_any_instance_of(Quote).to receive(:get_freshdesk_ticket).and_return fd_ticket
      allow(fd_ticket).to receive(:helpdesk_ticket).and_return fd_ticket
      allow_any_instance_of(ApplicationHelper).to receive(:parse_freshdesk_time).and_return Time.now

    end
      
    scenario 'A user can toggle quoted freshdesk text', js: true do
      visit edit_quote_path(quote)
      click_link 'Timeline'
      expect(page).not_to have_content "wasabi451"
      click_link 'Toggle Quoted Text'
      expect(page).to have_content "wasabi451"
      click_link 'Toggle Quoted Text'
      expect(page).not_to have_content "wasabi451"
    end
  end

end

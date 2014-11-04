require 'spec_helper'

describe 'shared/freshdesk_ticket.html.erb', story_70: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  context 'when the given quote has no fd_ticket id' do
    it 'displays a message informing the user to check their fd ticket id' do
      expect(quote).to receive(:no_ticket_id_entered?).and_return true
      render 'shared/freshdesk_ticket.html.erb', quote: quote
      expect(rendered).to have_text(I18n.t :quote_no_fd_id)
    end
  end

  context 'when CRM cannot find freshdesk login info' do
    it 'displays a message to configure their crm login' do
      expect(quote).to receive(:no_ticket_id_entered?).and_return false
      expect(quote).to receive(:no_fd_login?).and_return true
      render 'shared/freshdesk_ticket.html.erb', quote: quote
      expect(rendered).to have_text(I18n.t :quote_invalid_fd_id)
    end
  end

  context 'when the previous checks are valid but crm still can\'t talk to freshdesk' do
    it 'displays an error message informing the user that something\'s wrong' do
      expect(quote).to receive(:no_ticket_id_entered?).and_return false
      expect(quote).to receive(:no_fd_login?).and_return false
      expect(quote).to receive(:has_freshdesk_ticket?).and_return false
      render 'shared/freshdesk_ticket.html.erb', quote: quote
      expect(rendered).to have_text(I18n.t :quote_invalid_configuration)
    end
  end
end

include 'spec_helper'

describe 'shared/freshdesk_ticket.html.erb', story_70: true do
  context 'when the given quote has an invalid fd_ticket id' do
    it 'displays a message informing the user to check their fd ticket id' do
      # when a quote has an incorrect fd id, freshdesk's api will return a null json object
      render 'shared/freshdesk_ticket.html.erb', freshdesk_ticket: '{}'
      expect(rendered).to have_text(Figaro.env['quote_invalid_fd_id'])
    end
  end

  context 'when the quote has a correct freshdesk ticket_id' do
    it 'does not display an error message to the user' do
      render 'shared/freshdesk_ticket.html.erb', freshdesk_ticket: '{"valid_json": "true" }'
      expect(rendered).to_not have_text(Figaro.env['quote_invalid_fd_id'])
    end
  end
end

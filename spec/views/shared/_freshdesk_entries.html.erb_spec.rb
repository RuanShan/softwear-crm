require 'spec_helper'

describe 'shared/freshdesk_entries.html.erb', story_70: true do
  let!(:freshdesk_ticket) {
    {
      'created_at' => '2014-10-27T19:00:45-04:00',
      'display_id' => 63820,
      'subject' => 'Re: From The Ann Arbor T-Shirt Company -
                    Custom order proofs for Nerd Life Productions!',
      'ticket_type' => 'Full Proof Approval',
      'requester_name' => 'Nerd Life Productions',
      'due_by' => '2014-10-29T19:00:45-04:00',
      'notes' => [
        {
          'note' => {
              'body_html' => '<div>See his message. One of them should be a purple hoodie</div>\r\n',
              'created_at' => '2014-10-27T20:05:40-04:00',
          }
        }
      ]
    }
  }
  it 'displays the appropriate information regarding the ticket' do
    render 'shared/freshdesk_entries', freshdesk_ticket: freshdesk_ticket
    expect(rendered).to have_text('Full Proof Approval')
    expect(rendered).to have_text('Nerd Life Productions')
    expect(rendered).to have_text('Re: From The Ann Arbor T-Shirt Company -
                                   Custom order proofs for Nerd Life Productions!')
  end
end

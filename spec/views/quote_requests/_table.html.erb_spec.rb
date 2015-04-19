require 'spec_helper'

describe 'quote_requests/_table.html.erb', quote_request: true, story_207: true do
  let!(:quote_request) { build_stubbed(:quote_request) }
  let!(:quote_requests) { assign(:quote_requests, [quote_request]) }

  before(:each) do
    render partial: 'quote_requests/table', locals: { quote_requests: quote_requests }
  end

  it 'displays the correct fields for the quote requests' do
    expect(rendered).to have_selector('th', text: 'Requester')
    expect(rendered).to have_selector('th', text: 'Est. Qty')
    expect(rendered).to have_selector('th', text: 'Date Needed')
    expect(rendered).to have_selector('th', text: 'Salesperson')
    expect(rendered).to have_selector('th', text: 'Status')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

end
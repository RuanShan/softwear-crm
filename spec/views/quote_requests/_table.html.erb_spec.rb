require 'spec_helper'

describe 'quote_requests/_table.html.erb', quote_request: true, story_207: true do
  let!(:quote_request) { build_stubbed(:quote_request) }
  let!(:quote_requests) { assign(:quote_requests, [quote_request]) }

  before(:each) do
    render partial: 'quote_requests/table', locals: { quote_requests: quote_requests }
  end

  it 'displays the correct fields for the quote requests' do
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Email')
    expect(rendered).to have_selector('th', text: 'Est. Qty')
    expect(rendered).to have_selector('th', text: 'Date Needed')
    expect(rendered).to have_selector('th', text: 'Salesperson')
    expect(rendered).to have_selector('th', text: 'Status')
    expect(rendered).to have_selector('th', text: 'Generate Quotes')
  end

  it 'has a generate quote button' do
    expect(rendered).to have_css("a.btn-primary[href='#{ new_quote_path(name: quote_request.name, email: quote_request.email, quote_request_id: quote_request.id) }']")
  end
end
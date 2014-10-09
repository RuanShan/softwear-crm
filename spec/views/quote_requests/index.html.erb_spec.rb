require 'spec_helper'

describe 'quote_requests/index.html.erb', quote_request_spec: true, story_78: true do
  let!(:quote_requests) { [build_stubbed(:quote_request)] * 3 }

  it 'displays the names and emails of all the quote requests' do
    assign(:quote_requests, quote_requests)
    render

    quote_requests.each do |quote_request|
      expect(rendered).to have_content quote_request.name
      expect(rendered).to have_content quote_request.email
      expect(rendered).to have_content quote_request.date_needed.month
      expect(rendered).to have_content quote_request.date_needed.day
      expect(rendered).to have_content quote_request.date_needed.year
    end
  end
end
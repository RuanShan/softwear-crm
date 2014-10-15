require 'spec_helper'

describe 'quote_requests/show.html.erb', quote_request_spec: true, story_78: true do
  let!(:quote_request) { build_stubbed :quote_request }
  let!(:quotes) { [build_stubbed(:valid_quote), build_stubbed(:valid_quote)] }

  before(:each) do
    allow(quote_request).to receive(:quotes).and_return quotes
    quotes.each_with_index do |quote, i|
      allow(quote).to receive(:id).and_return i
    end
  end

  it 'displays all fields of the quote request + links to quotes', story_195: true do
    assign(:quote_request, quote_request)
    render

    expect(rendered).to have_content quote_request.name
    expect(rendered).to have_content quote_request.email
    expect(rendered).to have_content quote_request.approx_quantity
    expect(rendered).to have_content quote_request.date_needed.month
    expect(rendered).to have_content quote_request.date_needed.day
    expect(rendered).to have_content quote_request.date_needed.year
    expect(rendered).to have_content quote_request.description
    expect(rendered).to have_content quote_request.source
    expect(rendered).to have_content quote_request.status

    quotes.each do |quote|
      expect(rendered).to have_css "a[href='#{quote_path(quote.id)}']", text: quote.name
    end
  end
end
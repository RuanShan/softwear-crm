require 'spec_helper'

describe 'quote_requests/show.html.erb', quote_request_spec: true, story_78: true do
  let!(:quote_request) { build_stubbed :quote_request }

  it 'displays all fields of the quote request' do
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
  end
end
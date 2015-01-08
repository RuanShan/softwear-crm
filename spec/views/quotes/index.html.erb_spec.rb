require 'spec_helper'

describe 'quotes/index.html.erb', quote_spec: true, story_306: true do
  let!(:quote) { create(:valid_quote) }

  before(:each) do
    assign(:quotes, Quote.all.page)
    render file: 'quotes/index'
  end

  it 'Should have a table header with appropriate headings' do
    expect(rendered).to have_css('th', text: 'Customer')
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Valid Until')
    expect(rendered).to have_css('th', text: 'Est. Delivery Date')
    expect(rendered).to have_css('th', text: 'Salesperson')
    expect(rendered).to have_css('th', text: 'Store')
  end

  it 'should have a tbody with the quote information' do
    expect(rendered).to have_css('td', text: quote.full_name)
    expect(rendered).to have_css('td', text: quote.email)
    expect(rendered).to have_css('td', text: quote.company)
    expect(rendered).to have_css('td', text: quote.phone_number)
    expect(rendered).to have_css('td', text: quote.twitter)
  end
end

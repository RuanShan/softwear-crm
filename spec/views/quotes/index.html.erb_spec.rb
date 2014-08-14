require 'spec_helper'

describe 'quotes/index.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    assign(:quotes, [quote])
    render file: 'quotes/index'
  end

  it 'Should have a table header with appropriate headings' do
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Email')
    expect(rendered).to have_css('th', text: 'Phone')
    expect(rendered).to have_css('th', text: 'Company')
    expect(rendered).to have_css('th', text: 'Twitter')
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Valid until date')
    expect(rendered).to have_css('th', text: 'Estimated delivery date')
    expect(rendered).to have_css('th', text: 'Salesperson')
    expect(rendered).to have_css('th', text: 'Store')
  end

  it 'should have a tbody with the quote information' do
    expect(rendered).to have_css('td', text: quote.full_name)
    expect(rendered).to have_css('td', text: quote.email)
    expect(rendered).to have_css('td', text: quote.phone_number)
    expect(rendered).to have_css('td', text: quote.company)
    expect(rendered).to have_css('td', text: quote.twitter)
    expect(rendered).to have_css('td', text: quote.name)
    expect(rendered).to have_css('td', text: quote.valid_until_date)
    expect(rendered).to have_css('td', text: quote.estimated_delivery_date)
    expect(rendered).to have_css('td', text: quote.salesperson.full_name)
    expect(rendered).to have_css('td', text: quote.store.name)
  end
end

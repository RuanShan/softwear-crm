require 'spec_helper'

describe 'quotes/show.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    assign(:quote, quote)
    render file: 'quotes/show', id: quote.to_param
  end

  it 'should display a div containing Customer Information' do
    expect(rendered).to have_css('h2', text: 'Customer Information')
    expect(rendered).to have_css('label', text: 'Email:')
    expect(rendered).to have_css('label', text: 'Phone Number:')
    expect(rendered).to have_css('label', text: 'First Name:')
    expect(rendered).to have_css('label', text: 'Last Name:')
    expect(rendered).to have_css('label', text: 'Company:')
    expect(rendered).to have_css('label', text: 'Twitter:')

    expect(rendered).to have_content(quote.email)
    expect(rendered).to have_content(quote.phone_number)
    expect(rendered).to have_content(quote.first_name)
    expect(rendered).to have_content(quote.last_name)
    expect(rendered).to have_content(quote.company)
    expect(rendered).to have_content(quote.twitter)
  end

  it 'should display a div containing the Quote Details' do
    expect(rendered).to have_css('h2', text: 'Quote Details')
    expect(rendered).to have_css('label', text: 'Name:')
    expect(rendered).to have_css('label', text: 'Valid Until:')
    expect(rendered).to have_css('label', text: 'Estimated Delivery:')
    expect(rendered).to have_css('label', text: 'Salesperson:')
    expect(rendered).to have_css('label', text: 'Store:')

    expect(rendered).to have_content(quote.name)
    expect(rendered).to have_content(display_time(quote.valid_until_date))
    expect(rendered).to have_content(display_time(quote.estimated_delivery_date))
    expect(rendered).to have_content(quote.salesperson.full_name)
    expect(rendered).to have_content(quote.store.name)
  end

  it 'should contain a link to initiate a print' do
    expect(rendered).to have_css('a', text: 'Print')
  end

  it 'should contain a button to email a customer' do
    expect(rendered).to have_link('Email Quote')
  end
end

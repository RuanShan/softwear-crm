require 'spec_helper'

describe 'quotes/show.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    assign(:quote, quote)
    render file: 'quotes/show', id: quote.to_param
  end

  it 'should display a div containing Customer Information' do
    expect(rendered).to have_css('h2', text: 'Customer Details')
    expect(rendered).to have_css('dt', text: 'E-mail')
    expect(rendered).to have_css('dt', text: 'Phone Number')
    expect(rendered).to have_css('dt', text: 'Name')
    expect(rendered).to have_css('dt', text: 'Company')

    expect(rendered).to have_content(quote.email)
    expect(rendered).to have_content(quote.phone_number)
    expect(rendered).to have_content(quote.full_name)
    expect(rendered).to have_content(quote.company)
  end

  it 'should display a div containing the Quote Details' do
    expect(rendered).to have_css('h2', text: 'Quote Details')
    expect(rendered).to have_css('dt', text: 'Name')
    expect(rendered).to have_css('dt', text: 'Valid Until')
    expect(rendered).to have_css('dt', text: 'Estimated Delivery')
    expect(rendered).to have_css('dt', text: 'Salesperson')

    expect(rendered).to have_content(quote.name)
    expect(rendered).to have_content(display_time(quote.valid_until_date))
    expect(rendered).to have_content(display_time(quote.estimated_delivery_date))
    expect(rendered).to have_content(quote.salesperson.full_name)
  end

  it 'should contain a link to initiate a print' do
    expect(rendered).to have_css('a', text: 'Print')
  end

  it 'should contain a button to email a customer' do
    expect(rendered).to have_link('Email Quote')
  end
end

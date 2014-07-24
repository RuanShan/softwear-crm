require 'spec_helper'

describe 'quotes/_line_item_information.html.erb', quote_spec: true do
  login_user

  let!(:quote) { create(:valid_quote) }
  before(:each) do
    assign(:quote, quote)
    render partial: 'quotes/line_item_information'
  end

  it 'should have a table header with line item attributes' do
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Description')
    expect(rendered).to have_css('th', text: 'Unit Price')
    expect(rendered).to have_css('th', text: 'Quantity')
    expect(rendered).to have_css('th', text: 'Totals')
  end

  it 'should have appropriate td\'ss for line item attributes' do
    expect(rendered).to have_css('td', text: quote.standard_line_items.first.name)
    expect(rendered).to have_css('td', text: quote.standard_line_items.first.description)
    expect(rendered).to have_css('td', text: number_to_currency(quote.standard_line_items.first.unit_price))
    expect(rendered).to have_css('td', text: quote.standard_line_items.first.quantity)
    expect(rendered).to have_css('td', text: number_to_currency(quote.standard_line_items.first.price))
  end
end

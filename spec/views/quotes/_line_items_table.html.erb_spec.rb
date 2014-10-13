require 'spec_helper'

describe 'quotes/_line_items_table.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }
  let!(:line_item) { build_stubbed(:non_imprintable_line_item) }
  let!(:line_item_group) { double(:line_item_group, line_items: [line_item]) }

  before(:each) do
    allow(quote).to receive(:line_item_groups).and_return [line_item_group]
    render partial: 'quotes/line_items_table', locals: { quote: quote }
  end

  it 'should have a table header with line item attributes' do
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Description')
    expect(rendered).to have_css('th', text: 'Unit Price')
    expect(rendered).to have_css('th', text: 'Quantity')
    expect(rendered).to have_css('th', text: 'Totals')
  end

  it "should have appropriate td's for line item attributes" do
    expect(rendered).to have_css('td', text: quote.standard_line_items.first.name)
    expect(rendered).to have_css('td', text: quote.standard_line_items.first.description)
    expect(rendered).to have_css('td', text: number_to_currency(quote.standard_line_items.first.unit_price))
    expect(rendered).to have_css('td', text: quote.standard_line_items.first.quantity)
    expect(rendered).to have_css('td', text: number_to_currency(quote.standard_line_items.first.total_price))
  end
end
require 'spec_helper'

describe 'quotes/_line_item_information.html.erb', quote_spec: true, story_75: true do
  let!(:quote) { build_stubbed(:valid_quote) }
  let!(:line_item) { build_stubbed(:non_imprintable_line_item) }
  let!(:line_item_group) { double(:line_item_group, line_items: [line_item]) }

  before(:each) do
    allow(quote).to receive(:line_item_groups).and_return [line_item_group, line_item_group]
    allow(line_item_group).to receive(:name).and_return ('Whats yo name?!?!')
    render 'quotes/line_item_information', quote: quote
  end

  context 'when the quote is formal', story_277: true do
    before(:each) do
      quote.informal = false
    end

    it 'has a table header with Name, Description, Unit Price, Quantity, and Totals' do
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

    it 'displays subtotal' do
      expect(rendered).to have_css 'id > strong', text: 'Subtotal:'
    end
    it 'displays shipping' do
      expect(rendered).to have_css 'id > strong', text: 'Shipping:'
    end
  end

  context 'when the quote is informal', story_277: true do
    before(:each) do
      quote.informal = true
    end

    it 'should omit the Totals header' do
      expect(rendered).to have_css('th', text: 'Name')
      expect(rendered).to have_css('th', text: 'Description')
      expect(rendered).to have_css('th', text: 'Unit Price')
      expect(rendered).to have_css('th', text: 'Quantity')
      expect(rendered).to_not have_css('th', text: 'Totals')
    end

    it 'should omit the total price' do
      expect(rendered).to have_css('td', text: quote.standard_line_items.first.name)
      expect(rendered).to have_css('td', text: quote.standard_line_items.first.description)
      expect(rendered).to have_css('td', text: number_to_currency(quote.standard_line_items.first.unit_price))
      expect(rendered).to have_css('td', text: quote.standard_line_items.first.quantity)
      expect(rendered).to_not have_css('td', text: number_to_currency(quote.standard_line_items.first.total_price))
    end

    it 'does not display subtotal' do
      expect(rendered).to_not have_css 'id > strong', text: 'Subtotal:'
    end
    it 'does not display shipping' do
      expect(rendered).to_not have_css 'id > strong', text: 'Shipping:'
    end
  end

  context 'line item with url' do
    let!(:line_item) { build_stubbed(:non_imprintable_line_item, url: 'google.com') }

    it 'should link to the line item via its name if url is not blank' do
      expect(rendered).to have_css('a', text: quote.standard_line_items.first.name)
      expect(rendered).to have_link("#{quote.standard_line_items.first.name}", href: "http://#{quote.standard_line_items.first.url}")
    end
  end

  context 'line item without url' do
    let!(:line_item) { build_stubbed(:non_imprintable_line_item, url: nil) }

    it 'should not link to the line item via its name if url is blank' do
      expect(rendered).to_not have_css('a', text: quote.standard_line_items.first.name)
      expect(rendered).to_not have_link("#{quote.standard_line_items.first.name}", href: "http://#{quote.standard_line_items.first.url}")
    end
  end
end

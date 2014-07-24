require 'spec_helper'

describe 'quotes/edit.html.erb', quote_spec: true do
  let!(:quote) { create(:valid_quote) }
  login_user

  before(:each) do
    assign(:quote, quote)
    render file: 'quotes/edit'
  end

  it 'Should have a tabbed display with a timeline, details, line_items, and actions' do
    expect(rendered).to have_css('a[href="#timeline"]', text: 'Timeline')
    expect(rendered).to have_css('a[href="#details"]', text: 'Details')
    expect(rendered).to have_css('a[href="#line_items"]', text: 'Line Items')
    expect(rendered).to have_css('a[href="#actions"]', text: 'Actions')
  end

  it 'should contain divs with ids equal to timeline, details, line_items and actions' do
    expect(rendered).to have_css('div#timeline')
    expect(rendered).to have_css('div#details')
    expect(rendered).to have_css('div#line_items')
    expect(rendered).to have_css('div#actions')
  end

  it 'should contain a link to print the quote' do
    expect(rendered).to have_css('a', text: 'Print Quote')
  end
end

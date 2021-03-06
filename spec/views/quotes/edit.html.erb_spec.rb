require 'spec_helper'

describe 'quotes/edit.html.erb', quote_spec: true do
  login_user

  let!(:quote) { build_stubbed(:valid_quote) }
  let!(:activity) { create(:quote_activity_update) }

  before(:each) do
    assign(:quote, quote)
    render file: 'quotes/edit'
  end

  it 'Should have a tabbed display with a timeline, details, line_items, and actions' do
    expect(rendered).to have_css('a[href="#details"]', text: 'Details')
    expect(rendered).to have_css('a[href="#line_items"]', text: 'Line Items')
    expect(rendered).to have_css('a[href="#timeline"]', text: 'Timeline')
  end

  it 'should contain divs with ids equal to timeline, details, line_items and actions' do
    expect(rendered).to have_css('div#details')
    expect(rendered).to have_css('div#line_items')
    expect(rendered).to have_css('div#timeline')
  end

  it 'should render the navbar' do
    expect(rendered).to have_css("#quote_nav")
  end

  it 'displays the line items tab by default' do
    render
    expect(rendered).to have_css("li.active", text: 'Line Items')
    expect(rendered).to have_css("#line_items.active")
  end

end

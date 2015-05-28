require 'spec_helper'

describe 'quotes/edit.html.erb', quote_spec: true do
  login_user

  let!(:quote) { build_stubbed(:valid_quote) }
  let!(:activity) { create(:quote_activity) }

  before(:each) do
    assign(:quote, quote)
    render file: 'quotes/edit'
  end

  it 'Should have a tabbed display with a timeline, details, line_items, and actions' do
    expect(rendered).to have_css('a[href="#timeline"]', text: 'Timeline')
    expect(rendered).to have_css('a[href="#details"]', text: 'Details')
    expect(rendered).to have_css('a[href="#line_items"]', text: 'Line Items')
    expect(rendered).to have_css('a[href="#quote_actions"]', text: 'Actions')
  end

  it 'should contain divs with ids equal to timeline, details, line_items and actions' do
    expect(rendered).to have_css('div#timeline')
    expect(rendered).to have_css('div#details')
    expect(rendered).to have_css('div#line_items')
    expect(rendered).to have_css('div#quote_actions')
  end

  it 'should contain a link to print the quote' do
    expect(rendered).to have_css('a', text: 'Print Quote')
  end

  it 'should contain a link to create order from quote' do
    expect(rendered).to have_css('a', text: 'Create Order from Quote')
  end

  it 'should have added quote entry in timeline' do
    expect(activity["first_name"]["new"]["Bob"])
    expect(activity["is_rushed"]["new"][true])
  #  expect(rendered).to have_content("Added a quote")
    expect(rendered).to have_content("Updated quote:")
    expect(rendered).to have_content("is_rushed was changed from false to true")
    expect(rendered).to have_content("first_name was changed from Jim to Bob")
  end

  it 'should have added new group entry in timeline' do
    expect(rendered).to have_content("with a quantity of 12")  
    expect(rendered).to have_content("with a decoration price of $6.66")  
    expect(rendered).to have_content("with an imprintable price of $3.33")  
  end

end

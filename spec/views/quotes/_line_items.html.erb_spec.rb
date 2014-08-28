require 'spec_helper'

describe 'quotes/_line_items.html.erb', quote_spec: true do
  before(:each) do
    render partial: 'quotes/line_items', locals: { quote: build_stubbed(:valid_quote) }
  end

  it 'should have a heading and two buttons to add and update line_items' do
    expect(rendered).to have_css('h3', text: 'Editing Line Items')
    expect(rendered).to have_css('a', text: 'Add Line Item')
    expect(rendered).to have_css('button', text: 'Update Line Items')
  end
end
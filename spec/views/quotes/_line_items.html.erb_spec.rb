require 'spec_helper'

describe 'quotes/_line_items.html.erb', quote_spec: true do
  login_user

  let!(:quote) { create(:valid_quote) }
  before(:each) do
    assign(:quote, quote)
    render partial: 'quotes/line_items'
  end

  it 'should have a heading and two buttons to add and update line_items' do
    expect(rendered).to have_css('h3', text: 'Editing Line Items')
    expect(rendered).to have_css('a', text: 'Add Line Item')
    expect(rendered).to have_css('button', text: 'Update Line Items')
  end
end
require 'spec_helper'

describe 'quotes/_actions.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    assign(:quote, quote)
    render partial: 'quotes/actions'
  end

  it 'should display a button to Email a Quote' do
    expect(rendered).to have_css('a', text: 'Email Quote')
  end
end

require 'spec_helper'

describe 'quotes/_actions.html.erb', quote_spec: true do
  before(:each) { render 'quotes/actions', quote: build_stubbed(:valid_quote) }

  it 'should display a button to Email a Quote' do
    expect(rendered).to have_css('a', text: 'Prepare for FreshDesk')
  end
end

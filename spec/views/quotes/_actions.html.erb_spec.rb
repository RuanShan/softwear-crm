require 'spec_helper'

describe 'quotes/_actions.html.erb', quote_spec: true do
  before(:each) do
    render partial: 'quotes/actions', locals: { quote: build_stubbed(:valid_quote) }
  end

  it 'should display a button to Email a Quote' do
    expect(rendered).to have_css('a', text: 'Email Quote')
  end
end

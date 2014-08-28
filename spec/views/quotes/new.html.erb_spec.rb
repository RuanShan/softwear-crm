require 'spec_helper'

describe 'quotes/new.html.erb', quote_spec: true do
  login_user

  before(:each) do
    assign(:quote, Quote.new)
    assign(:new_quote_hash, {})
    render file: 'quotes/new'
  end

  it 'Should have a header with "Create New Custom Quote Wizard"' do
    expect(rendered).to have_css('h1', text: 'Create New Custom Quote wizard')
  end
end

require 'spec_helper'

describe 'quotes/_actions.html.erb', quote_spec: true do
  let!(:quote) { create(:valid_quote) }
  login_user

  it 'should display a button to Email a Quote' do
    assign(:quote, quote)
    render partial: 'quotes/actions'
    expect(rendered).to have_css('a', text: 'Email Quote')
  end
end

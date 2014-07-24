require 'spec_helper'

describe 'quotes/_details.html.erb', quote_spec: true do
  login_user

  let!(:quote) { create(:valid_quote) }

  before(:each) do
    assign(:quote, quote)
    render partial: 'quotes/details', locals: { quote: quote }
  end

  it 'should contain a section for customer details and one for quote details' do
    expect(rendered).to have_css('.col-sm-6 h3', text: 'Customer Details')
    expect(rendered).to have_css('.col-sm-6 h3', text: 'Quote Details')
  end
end

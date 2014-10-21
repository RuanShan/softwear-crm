require 'spec_helper'

describe 'quotes/_customer_detail_fields.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    assign(:quote, quote)
    form_for(quote, url: quote_path(quote), builder: LancengFormBuilder) do |f|
      @f = f
    end
    render partial: 'quotes/customer_detail_fields', locals: { f: @f, email: nil, name: nil, quote: quote }
  end

  it 'should contain labels for email, phone number, first name, last name, company, and twitter' do
    expect(rendered).to have_css('label', text: 'Email')
    expect(rendered).to have_css('label', text: 'Phone Number')
    expect(rendered).to have_css('label', text: 'First Name')
    expect(rendered).to have_css('label', text: 'Last Name')
    expect(rendered).to have_css('label', text: 'Company')
    expect(rendered).to have_css('label', text: 'Twitter')
  end

  it 'should contain corresponding inputs as well' do
    expect(rendered).to have_css('input#quote_email')
    expect(rendered).to have_css('input#quote_phone_number')
    expect(rendered).to have_css('input#quote_first_name')
    expect(rendered).to have_css('input#quote_last_name')
    expect(rendered).to have_css('input#quote_company')
    expect(rendered).to have_css('input#quote_twitter')
  end
end

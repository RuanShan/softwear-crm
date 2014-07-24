require 'spec_helper'

describe 'quotes/email_customer.html.erb', quote_spec: true do
  let!(:quote) { create(:valid_quote) }
  login_user

  before(:each) do
    assign(:quote, quote)
    render file: 'quotes/email_customer'
  end

  it 'Should have a form with two fields' do
    expect(rendered).to have_css('label', text: 'Subject')
    expect(rendered).to have_css('label', text: 'Body of email')
    expect(rendered).to have_css('input#email_subject')
    expect(rendered).to have_css('textarea#email_body.summernote')
  end
end

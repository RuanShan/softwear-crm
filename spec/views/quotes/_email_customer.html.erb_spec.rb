require 'spec_helper'

describe 'quotes/_email_customer.html.erb', quote_spec: true do
  let!(:quote) { create(:valid_quote) }
  login_user

  before(:each) do
    assign(:quote, quote)
    render partial: 'quotes/email_customer'
  end

  it 'Should have a form with two fields' do
    expect(rendered).to have_css('label', text: 'Subject')
    expect(rendered).to have_css('label', text: 'Body of Email')
    expect(rendered).to have_css('input#email_subject')
    expect(rendered).to have_css('textarea.summernote')
  end
end

require 'spec_helper'

describe 'quotes/_email_customer.html.erb', quote_spec: true do
  before(:each) do
    render partial: 'quotes/email_customer', locals: { quote: build_stubbed(:valid_quote) }
  end

  it 'Should have a form with three fields' do
    expect(rendered).to have_css('label', text: 'Subject')
    expect(rendered).to have_css('label', text: 'Email Recipients (separated by commas)')
    expect(rendered).to have_css('label', text: 'Body of Email')
    expect(rendered).to have_css('input#email_subject')
    expect(rendered).to have_css('input#email_recipients')
    expect(rendered).to have_css('textarea.summernote')
  end
end

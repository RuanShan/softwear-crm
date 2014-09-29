require 'spec_helper'

describe 'quotes/_email_customer.html.erb', quote_spec: true do
  before(:each) do
    render 'email_customer',
            quote: build_stubbed(:valid_quote),
            current_user: build_stubbed(:alternate_user)
  end

  it 'Should have a form with four fields' do
    expect(rendered).to have_css('label', text: 'Subject')
    expect(rendered).to have_css('label', text: 'Email Recipients (separated by commas)')
    expect(rendered).to have_css('label', text: 'Body of Email')
    expect(rendered).to have_css('input#email_subject')
    expect(rendered).to have_css('input#email_recipients')
    expect(rendered).to have_css('input#cc')
    expect(rendered).to have_css('textarea.summernote')
  end
end

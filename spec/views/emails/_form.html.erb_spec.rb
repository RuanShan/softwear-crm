require 'spec_helper'

describe 'emails/_form.html.erb' do
  let!(:quote) { create(:valid_quote) }
  let!(:email) { Email.new(emailable: quote, emailable_type: 'Quote') }

  it 'has all fields visible' do
    render 'emails/form', object: quote, email: email
    expect(rendered).to have_content("Subject")
    expect(rendered).to have_content("To")
    expect(rendered).to have_content("From")
    expect(rendered).to have_content("Cc")
    expect(rendered).to have_content("Bcc")
    expect(rendered).to have_content("Plaintext body")
  end

  it 'has only body and template visible when freshdesk=true' do
    assign(:freshdesk, true)
    render 'emails/form', object: quote, email: email
    expect(rendered).not_to have_content("Subject")
    expect(rendered).not_to have_content("To")
    expect(rendered).not_to have_content("From")
    expect(rendered).not_to have_content("Cc")
    expect(rendered).not_to have_content("Bcc")
    expect(rendered).not_to have_content("Plaintext body")
    
    expect(rendered).to have_content("Body")
  end
end

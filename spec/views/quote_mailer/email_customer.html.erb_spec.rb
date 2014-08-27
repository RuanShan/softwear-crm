require 'spec_helper'

describe 'quote_mailer/email_customer.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    assign(:body, "#{quote.name} #{quote.first_name} #{quote.last_name}")
    render
  end

  it 'includes the body of the email' do
    expect(rendered).to have_text("#{quote.name} #{quote.first_name} #{quote.last_name}")
  end
end

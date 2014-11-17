require 'spec_helper'

describe 'quotes/populate_email.html.erb', quote_spec: true, story_207: true do
  let!(:quote) { create(:valid_quote) }
  let!(:current_user) { create(:user) }

  before(:each) do
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:quote, quote)
    render file: 'quotes/populate_email', locals: { quote: quote }
  end

  it 'should render _email_customer.html.erb' do
    expect(rendered).to render_template(partial: '_email_customer')
  end
end

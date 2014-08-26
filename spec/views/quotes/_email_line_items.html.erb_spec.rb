require 'spec_helper'

describe 'quotes/_email_line_items.html.erb', quote_spec: true do
  let!(:quote) { build_stubbed(:valid_quote) }
  let!(:line_item) { build_stubbed(:non_imprintable_line_item) }

  before(:each) do
    allow(quote).to receive(:standard_line_items).and_return([line_item])
    render partial: 'quotes/email_line_items', locals: { quote: quote }
  end

  it 'greets the customer' do
    expect(rendered).to have_content('Thank you for your interest in Ann Arbor Tees!')
    expect(rendered).to have_content('We appreciate the opportunity to work with you!')
  end

  it 'tells the customer there is a quote ready' do
    expect(rendered).to have_content('I went ahead and put together a quote for you and it\'s included below.')
  end

  it 'offers availability' do
    expect(rendered).to have_content('Let me know if you have any questions whatsoever or would like some clarification.')
  end

  it 'includes the fine print' do
    expect(rendered).to have_content('The Fine Print')
    expect(rendered).to have_content('Quote Expiration')
    expect(rendered).to have_content('Regarding Payment')
    expect(rendered).to have_content('Regarding Garment Availability')
  end
end

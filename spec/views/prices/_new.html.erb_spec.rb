require 'spec_helper'

describe 'prices/_new.html.erb', prices_spec: true do
  let!(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    session = { pricing_groups: {} }
    render 'prices/new', imprintable: imprintable, session: session
  end

  it 'should contain a decoration price field and a button' do
    expect(rendered).to have_content 'Decoration Price'
    expect(rendered).to have_css('button', text: 'Add to Pricing Table')
  end
end

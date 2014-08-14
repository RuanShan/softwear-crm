require 'spec_helper'

describe 'prices/_new.html.erb', prices_spec: true do
  let!(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    render partial: 'prices/new', locals: { imprintable: imprintable }
  end

  it 'should contain a decoration price field and a button' do
    expect(rendered).to have_content 'Decoration Price'
    expect(rendered).to have_css('button', text: 'Fetch Prices!')
  end
end

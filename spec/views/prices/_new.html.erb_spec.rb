require 'spec_helper'

describe 'prices/_new.html.erb', prices_spec: true do
  let!(:imprintable) { create(:valid_imprintable) }
  it 'should contain a decoration price field and a button' do
    render partial: 'prices/new', locals: { imprintable: imprintable }

    expect(rendered).to have_content 'Decoration Price'
    expect(rendered).to have_css('button', text: 'Fetch Prices!')
  end
end

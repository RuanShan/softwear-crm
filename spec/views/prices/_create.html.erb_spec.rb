require 'spec_helper'

describe 'prices/_create.html.erb', prices_spec: true do
  it 'displays a table with the pricing information' do
    prices_hash = {
        base_price: 10,
        xxl_price: 12,
        xxxl_price: 13,
        xxxxl_price: 14,
        xxxxxl_price: 15,
        xxxxxxl_price: 16
    }

    render partial: 'prices/create', locals: { prices_hash: prices_hash }

    expect(rendered).to have_css('td', text: '10')
    expect(rendered).to have_css('td', text: '12')
    expect(rendered).to have_css('td', text: '13')
    expect(rendered).to have_css('td', text: '14')
    expect(rendered).to have_css('td', text: '15')
    expect(rendered).to have_css('td', text: '16')
    expect(rendered).to have_content('Base Price')
    expect(rendered).to have_content('2XL')
    expect(rendered).to have_content('3XL')
    expect(rendered).to have_content('4XL')
    expect(rendered).to have_content('5XL')
    expect(rendered).to have_content('6XL')
  end
end

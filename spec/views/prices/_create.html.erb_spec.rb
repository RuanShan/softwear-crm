require 'spec_helper'

describe 'prices/_create.html.erb', prices_spec: true do
  let!(:imprintable) { create(:valid_imprintable) }
  it 'displays a table with the pricing information' do

    render partial: 'prices/create', locals: { imprintable: imprintable, session: { prices: [imprintable.pricing_hash(2)] } }

    expect(rendered).to have_css('td', text: imprintable.name)
    expect(rendered).to have_css('td', text: imprintable.sizes.map(&:display_value).join(', '))
    expect(rendered).to have_css('td', text: '11.99')
    expect(rendered).to have_css('td', text: '12.00')
    expect(rendered).to have_css('td', text: '13.99')
    expect(rendered).to have_css('td', text: '14.99')
    expect(rendered).to have_css('td', text: '15.99')
    expect(rendered).to have_css('td', text: '--')
    expect(rendered).to have_content('Item')
    expect(rendered).to have_content('Sizes')
    expect(rendered).to have_content('Base Price')
    expect(rendered).to have_content('2XL')
    expect(rendered).to have_content('3XL')
    expect(rendered).to have_content('4XL')
    expect(rendered).to have_content('5XL')
    expect(rendered).to have_content('6XL')
  end
end

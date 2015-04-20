require 'spec_helper'

describe 'prices/_create.html.erb', prices_spec: true do
  let!(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    allow(imprintable).to receive(:name).and_return('Name')
    session = {
      pricing_groups: { pricing_group_one: [imprintable.pricing_hash(2)] }
    }
    render 'prices/create', imprintable: imprintable, session: session
  end

  it 'displays a the table headers' do
    expect(rendered).to have_content('Item')
    expect(rendered).to have_content('Sizes')
    expect(rendered).to have_content('Base')
    expect(rendered).to have_content('2XL')
    expect(rendered).to have_content('3XL')
    expect(rendered).to have_content('4XL')
    expect(rendered).to have_content('5XL')
    expect(rendered).to have_content('6XL')
  end

  it 'displays the pricing information' do
    expect(rendered).to have_css('td', text: imprintable.name)
    expect(rendered).to have_css('td', text: imprintable.sizes.map(&:display_value).join(', '))
    expect(rendered).to have_css('td', text: '11.99')
    expect(rendered).to have_css('td', text: '12.00')
    expect(rendered).to have_css('td', text: '13.99')
    expect(rendered).to have_css('td', text: '14.99')
    expect(rendered).to have_css('td', text: '15.99')
    expect(rendered).to_not have_css('td', text: 'n/a')
  end

  it 'displays quantity', story_489: true do
    expect(rendered).to have_css('th', text: 'Quantity')
    expect(rendered).to have_css('td', text: '1')
  end
end

require 'spec_helper'

describe 'imprintables/show/_sales.html.erb', imprintable_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    allow(imprintable).to receive(:name).and_return('name')
    render partial: 'imprintables/show/sales',
           locals: { imprintable: imprintable }
  end

  it 'display main supplier, supplier link, name, and pricing' do
    expect(rendered).to have_css('h2', text: imprintable.main_supplier)
    expect(rendered).to have_css('dd', text: imprintable.supplier_link)
    # imprintable Category
    # Coordinates
    # Sample Locations
    # Tags
    # Pricing Upcharges


    expect(rendered).to have_css('td', text: imprintable.base_price)
    expect(rendered).to have_css('td', text: imprintable.xxl_price)
    expect(rendered).to have_css('td', text: imprintable.xxxl_price)
    expect(rendered).to have_css('td', text: imprintable.xxxxl_price)
    expect(rendered).to have_css('td', text: imprintable.xxxxxl_price)
    expect(rendered).to have_css('td', text: imprintable.xxxxxxl_price)
  end
end

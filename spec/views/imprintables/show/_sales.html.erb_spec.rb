require 'spec_helper'

describe 'imprintables/show/_sales.html.erb', imprintable_spec: true do

  let(:imprintable) { build(:valid_imprintable, tag: "Standard") }

  before(:each) do
    allow(imprintable).to receive(:name).and_return('name')
    allow(imprintable).to receive(:brand).and_return(build(:valid_brand))
    imprintable.xxxxxxl_price = nil
    render 'imprintables/show/sales', imprintable: imprintable
  end

  it 'display main supplier, supplier link, name, pricing, and shirt tag type' do

    expect(rendered).to have_css 'dd', text: imprintable.brand.name
    expect(rendered).to have_css 'dd', text: imprintable.style_name
    expect(rendered).to have_css 'dd', text: imprintable.style_catalog_no
    expect(rendered).to have_css 'dd', text: imprintable.description

    expect(rendered).to have_css 'td', text: imprintable.base_price
    expect(rendered).to have_css 'td', text: imprintable.xxl_price
    expect(rendered).to have_css 'td', text: imprintable.xxxl_price
    expect(rendered).to have_css 'td', text: imprintable.xxxxl_price
    expect(rendered).to have_css 'td', text: imprintable.xxxxxl_price
    expect(rendered).to_not have_css 'th', text: '6xl'

    expect(rendered).to have_css('dd', text: imprintable.main_supplier)
    expect(rendered).to have_css('dd', text: imprintable.supplier_link)
    expect(rendered).to have_content "Shirt Tag Type Standard"

  end

end

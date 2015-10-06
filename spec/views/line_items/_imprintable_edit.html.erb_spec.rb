require 'spec_helper'
include LineItemHelpers

describe 'line_items/_imprintable_edit.html.erb', line_item_spec: true do
  let!(:white) { create(:valid_color, name: 'white') }
  let!(:shirt) { create(:valid_imprintable) }
  make_variants :white, :shirt, [:S, :M, :L], not: [:job]

  let(:line_items) {[
    white_shirt_s_item,
    white_shirt_m_item,
    white_shirt_l_item
  ]}

  before(:each) do
    render partial: 'line_items/imprintable_edit',
      locals: {
        color_name: 'white',
        style_name: shirt.style_name,
        style_catalog_no: shirt.style_catalog_no,
        description: white_shirt_s_item.description,
        line_items: line_items,
        class_name: 'Job',
        show_prices: true
      }
  end

  it 'should render the filler div with the correct size' do
    expect(rendered).to have_css "div.col-sm-6"
  end

  it 'includes "Imprintable Info" and "Supplier" links', story_902: true do
    expect(rendered).to have_css 'a', text: 'Imprintable Info'
    expect(rendered).to have_css "a[href='#{shirt.supplier_link}']", text: 'Supplier'
  end
end

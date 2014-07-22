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
        class_name: 'Job'
      }
  end

  it 'should format the title of the line item set correctly' do
    expect(rendered).to have_css 'h6 > strong', text: "white #{shirt.style_name}"
    expect(rendered).to have_css 'p', text: white_shirt_s_item.description
  end

  it 'should render the filler div with the correct size' do
    expect(rendered).to have_css "div.col-sm-7"
  end
end
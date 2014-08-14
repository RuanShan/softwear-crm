require 'spec_helper'

describe 'line_items/_imprintable_edit_entry.html.erb', line_item_spec: true do
  let!(:line_item) { build_stubbed :imprintable_line_item }
  before(:each) do
    render partial: 'line_items/imprintable_edit_entry',
           locals: { line_item: line_item }
  end
  it 'renders inside a col-sm-1 div' do
    expect(rendered).to have_css 'div.col-sm-1'
  end
  it 'renders the size display value' do
    expect(rendered).to have_css 'label', text: 'display_value_'
  end
  it 'renders fields for quantity and unit_price' do
    expect(rendered)
      .to have_css "div > input[name='line_item[#{line_item.id}[quantity]]']"
    expect(rendered)
      .to have_css "div > input[name='line_item[#{line_item.id}[unit_price]]']"
  end
end

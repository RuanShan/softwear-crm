require 'spec_helper'

describe 'line_items/_imprintable_edit_entry.html.erb', line_item_spec: true do
  before(:each) do
    render partial: 'line_items/imprintable_edit_entry', locals: { line_item: create(:imprintable_line_item) }
  end
  it 'renders a form with just quantity and unit price' do
    within_form_for LineItem do
      expect(rendered).to have_field_for :quantity
      expect(rendered).to have_field_for :unit_price
    end
  end
  it 'renders inside a col-sm-1 div' do
    expect(rendered).to have_css 'div.col-sm-1'
  end
  it 'renders the size display value' do
    expect(rendered).to have_css 'label', text: 'display_value_'
  end
  it 'renders the fields within a div within the form' do
    expect(rendered).to have_css 'form > div > input[name="line_item[quantity]"]'
    expect(rendered).to have_css 'form > div > input[name="line_item[unit_price]"]'
  end
end
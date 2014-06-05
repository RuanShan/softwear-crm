require 'spec_helper'

describe 'line_items/_imprintable_form.html.erb', line_item_spec: true do
  it 'displays the correct fields' do
    render partial: 'line_items/imprintable_form', locals: {job: create(:job), line_item: LineItem.new}
    within_form_for LineItem do
    	expect(rendered).to have_field_for 'quantity', type: :number
      expect(rendered).to have_field_for 'unit_price', type: :number
      expect(rendered).to have_field_for 'brand'
      expect(rendered).to have_field_for 'style'
      expect(rendered).to have_field_for 'color'
    end
  end
end
require 'spec_helper'

describe 'line_items/_standard_form.html.erb', line_item_spec: true, story_75: true do
  it 'displays the correct fields' do
    assign(:line_itemable, create(:job))
    assign(:line_item, LineItem.new)
    render partial: 'line_items/standard_form'
    within_form_for LineItem do
      expect(rendered).to have_field_for 'name', type: :text
      expect(rendered).to have_field_for 'description'
      expect(rendered).to have_field_for 'quantity', type: :number
      expect(rendered).to have_field_for 'unit_price', type: :text
      expect(rendered).to have_field_for 'url', type: :text
    end
  end
end

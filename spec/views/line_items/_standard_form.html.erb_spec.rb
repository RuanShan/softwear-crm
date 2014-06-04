require 'spec_helper'

describe 'line_items/_standard_form.html.erb', line_item_spec: true do
  it 'displays the correct fields' do
    render partial: 'line_items/standard_form', locals: {job: create(:job), line_item: LineItem.new}
    within_form_for LineItem do
      expect(rendered).to have_field_for 'name'
      expect(rendered).to have_field_for 'description'
      expect(rendered).to have_field_for 'quantity'
      expect(rendered).to have_field_for 'unit_price'

      expect(rendered).to have_selector 'input[type="submit"][value="Add"]'
    end
  end
end
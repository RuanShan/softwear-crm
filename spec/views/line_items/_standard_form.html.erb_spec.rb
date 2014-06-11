require 'spec_helper'

describe 'line_items/_standard_form.html.erb', line_item_spec: true do
  it 'displays the correct fields' do
    render partial: 'line_items/standard_form', locals: {job: create(:job), line_item: LineItem.new}
    within_form_for LineItem do
      expect(rendered).to have_field_for 'name', type: :text
      expect(rendered).to have_field_for 'description'
      expect(rendered).to have_field_for 'quantity', type: :number
      expect(rendered).to have_field_for 'unit_price', type: :number
    end
  end
end
require 'spec_helper'

describe 'orders/_line_item_new_non_imprintable.html.erb', line_item_spec: true do
  it 'displays the correct fields' do
    render partial: 'orders/_line_item_new_non_imprintable', locals: {line_item: LineItem.new}
    within_form_for LineItem do
      expect(rendered).to have_field_for 'name'
      expect(rendered).to have_field_for 'description'
      expect(rendered).to have_field_for 'quantity'
      expect(rendered).to have_field_for 'unit_price'

      expect(rendered).to have_selector 'button', text: 'Add'
    end
  end
end
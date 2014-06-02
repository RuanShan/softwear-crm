require 'spec_helper'

describe 'orders/_line_item_new_imprintable.html.erb' do
  render partial: 'orders/_line_item_new_imprintable', locals: {line_item: LineItem.new}
  within_form_for LineItem do
    expect(rendered).to have_field_for 'brand'
    expect(rendered).to have_field_for 'style'
    expect(rendered).to have_field_for 'color'

    expect(rendered).to have_selector 'button', text: 'Add'
  end
end
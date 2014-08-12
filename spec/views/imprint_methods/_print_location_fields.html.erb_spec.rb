require 'spec_helper'

describe 'imprint_methods/_print_location_fields.html.erb', imprint_methods_spec: true do
  let(:imprint_method){ create(:valid_imprint_method_with_color_and_location) }

  it 'has input locations for name, max_height, max_width, and a remove button' do
    form_for(imprint_method){ |f| f.fields_for(:print_locations){ |ff| @f = ff } }
    render partial: 'imprint_methods/print_location_fields', locals: {f: @f}
    expect(rendered).to have_selector("input[id^='imprint_method_print_locations_attributes_'][id$='_name']")
    expect(rendered).to have_selector("input[id^='imprint_method_print_locations_attributes_'][id$='_max_height']")
    expect(rendered).to have_selector("input[id^='imprint_method_print_locations_attributes_'][id$='_max_width']")
    expect(rendered).to have_selector("a.js-remove-fields")
    expect(rendered).to have_selector("div.js-removeable")
  end
end
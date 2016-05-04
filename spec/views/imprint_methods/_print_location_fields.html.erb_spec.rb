require 'spec_helper'

describe 'imprint_methods/_print_location_fields.html.erb', imprint_method_spec: true do
  let(:imprint_method) { build_stubbed(:blank_imprint_method,
                                        ink_colors: [build_stubbed(:blank_ink_color)],
                                        print_locations: [build_stubbed(:blank_print_location)]) }

  it 'has input locations for name, max_height, max_width, and a remove button' do
    form_for(imprint_method, builder: NestedForm::Builder) { |f| f.fields_for(:print_locations) { |ff| @f = ff } }
    render partial: 'imprint_methods/print_location_fields', locals: {f: @f}
    expect(rendered).to have_selector("input[id^='imprint_method_print_locations_attributes_'][id$='_name']")
    expect(rendered).to have_selector("input[id^='imprint_method_print_locations_attributes_'][id$='_max_height']")
    expect(rendered).to have_selector("input[id^='imprint_method_print_locations_attributes_'][id$='_max_width']")
    expect(rendered).to have_selector('a.remove_nested_fields')
  end
end
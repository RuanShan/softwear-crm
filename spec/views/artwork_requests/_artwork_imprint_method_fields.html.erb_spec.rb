require 'spec_helper'

describe 'artwork_requests/_artwork_imprint_method_fields.html.erb', artwork_requests_spec: true do

  before do
    @imprint_method = build_stubbed(:blank_imprint_method)

    allow(@imprint_method).to receive(:print_locations) {[
      build_stubbed(:blank_print_location, name: 'Name')
    ]}

    allow(@imprint_method).to receive(:ink_colors) {[
      build_stubbed(:blank_ink_color, name: 'Name')
    ]}
  end

  before(:each){ render partial: 'artwork_imprint_method_fields', locals: { artwork_request: nil, imprint_method: @imprint_method } }

  it 'displays the correct form fields for print locations and ink colors' do
    expect(rendered).to have_selector('select#imprint_method_print_locations')
    expect(rendered).to have_selector('input#artwork_request_ink_color_ids_')
  end
end
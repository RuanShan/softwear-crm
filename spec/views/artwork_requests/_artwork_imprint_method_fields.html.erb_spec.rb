require 'spec_helper'

describe 'artwork_requests/_artwork_imprint_method_fields.html.erb', artwork_request_spec: true do

  let(:ink_color) { create(:ink_color) }

  before(:each) { render partial: 'artwork_imprint_method_fields', locals: { artwork_request: nil, ink_colors: [ink_color] } }

  it 'displays the correct form fields for print locations and ink colors' do
    expect(rendered).to have_selector('input#artwork_request_ink_color_ids_')
  end
end

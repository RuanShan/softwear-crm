require 'spec_helper'

describe 'artwork_requests/_artwork_imprint_method_fields.html.erb', artwork_requests_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:imprint_method){ create(:valid_imprint_method_with_color_and_location)}

  before(:each) do
    render partial: 'artwork_imprint_method_fields', locals: {artwork_request: artwork_request, imprint_method: imprint_method}
  end

    it 'displays the correct form fields for print locations and ink colors' do
      expect(rendered).to have_selector("select#imprint_method_print_locations")
      expect(rendered).to have_selector("input#artwork_request_ink_color_ids_")
    end
end
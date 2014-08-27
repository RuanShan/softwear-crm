require 'spec_helper'

describe 'artwork_requests/_form.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { build_stubbed(:blank_artwork_request) }
  let!(:order) { build_stubbed(:blank_order) }

  it 'displays the correct form fields for artwork_requests' do
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)) { |f| @f = f }
    render partial: 'artwork_requests/form', locals: { artwork_request: artwork_request, current_user: build_stubbed(:blank_user), f: @f, order: order }
    within_form_for ArtworkRequest do
      expect(rendered).to have_selector('select#artwork_request_job_ids')
      expect(rendered).to have_selector('select#artwork_request_priority')
      expect(rendered).to have_selector('select#artwork_imprint_method_fields')
      expect(rendered).to have_selector('div#imprint_method_print_locations_and_ink_colors')
      expect(rendered).to have_selector('select#artwork_request_artwork_status')
      expect(rendered).to have_selector('input#artwork_request_deadline')
      expect(rendered).to have_selector('select#artwork_request_artist_id')
      expect(rendered).to have_selector('input#artwork_request_description')
      expect(rendered).to have_selector('i.artwork-assets')
    end
  end
end
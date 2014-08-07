require 'spec_helper'

describe 'artwork_requests/_form.html.erb', artwork_requests_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:order){ create(:order_with_job)}

  it 'displays the correct form fields for artwork_requests' do
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)){|f| @f = f }
    render partial: 'artwork_requests/form', locals: {current_user: create(:user), order: order, artwork_request: ArtworkRequest.new, f: @f}
    within_form_for ArtworkRequest do
      expect(rendered).to have_selector("select#artwork_request_job_ids")
      expect(rendered).to have_selector("select#artwork_request_priority")
      expect(rendered).to have_selector("select#artwork_imprint_method_fields")
      expect(rendered).to have_selector("div#imprint_method_print_locations_and_ink_colors")
      expect(rendered).to have_selector("select#artwork_request_artwork_status")
      expect(rendered).to have_selector("input#artwork_request_deadline")
      expect(rendered).to have_selector("select#artwork_request_artist_id")
      expect(rendered).to have_selector("input#artwork_request_description")
      expect(rendered).to have_selector("i[class='fa fa-plus artwork-assets']")
    end
  end
end
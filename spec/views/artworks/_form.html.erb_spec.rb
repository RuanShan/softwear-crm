require 'spec_helper'

describe 'artwork_requests/_form.html.erb', artwork_request_spec: true do
  let!(:artwork){ create(:valid_artwork) }
  let!(:current_user){ create(:user) }


  it 'displays the correct form fields for artwork_requests' do
    form_for(artwork, url: artworks_path(artwork)){|f| @f = f }
    render partial: 'artworks/form', locals: {artwork: Artwork.new, f: @f, current_user: current_user}
    within_form_for Artwork do
      expect(rendered).to have_selector("input#artwork_name")
      expect(rendered).to have_selector("textarea#artwork_description")
      expect(rendered).to have_selector("input#artwork_tag_list")
      expect(rendered).to have_selector("label[for='artwork_artwork_attributes_file']")
      expect(rendered).to have_selector("label[for='artwork_preview_attributes_file']")
      expect(rendered).to have_selector("textarea#artwork_artwork_attributes_description")
      expect(rendered).to have_selector("textarea#artwork_preview_attributes_description")

    end
  end
end
require 'spec_helper'

describe 'artworks/_form.html.erb', artwork_spec: true do
  let!(:artwork) { build_stubbed(:blank_artwork) }

  it 'displays the correct form fields for artworks' do
    form_for(artwork, url: artworks_path(artwork)) { |f| @f = f }
    render partial: 'artworks/form', locals: { artwork: Artwork.new, current_user: build_stubbed(:blank_user), f: @f }
    within_form_for Artwork do
      expect(rendered).to have_selector('input#artwork_name')
      expect(rendered).to have_selector('textarea#artwork_description')
      expect(rendered).to have_selector('input#artwork_tag_list')
      expect(rendered).to have_selector("label[for='artwork_artwork_attributes_file']")
      expect(rendered).to have_selector("label[for='artwork_preview_attributes_file']")
      expect(rendered).to_not have_selector('textarea#artwork_artwork_attributes_description')
      expect(rendered).to_not have_selector('textarea#artwork_preview_attributes_description')
    end
  end
end

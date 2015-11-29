require 'spec_helper'

describe 'artworks/_asset_fields.html.erb', artwork_spec: true do
  let!(:artwork) { build_stubbed(:blank_artwork) }

  it 'displays the correct form fields for assets' do
    form_for(artwork, url: artworks_path(artwork)) { |f| f.fields_for(Asset.new, multipart: true) { |ff| @f = ff } }
    render partial: 'artworks/asset_fields', locals: { f: @f, file_constraints: 'File constraints', object: Asset.new, text: 'Text', title: 'Title' }
    within_form_for Asset do
      expect(rendered).to have_selector('input#artwork_asset_file')
      expect(rendered).to have_selector('textarea#artwork_asset_description')
    end
  end

end
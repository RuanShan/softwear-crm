require 'spec_helper'

describe 'artworks/_asset_fields.html.erb', artworks_spec: true do
  let!(:artwork){ create(:valid_artwork) }
  let!(:assets){ create(:valid_asset) }
  context 'no asset exists yet, i.e. new form' do
    it 'displays the correct form fields for assets' do

      form_for(artwork, url: artworks_path(artwork)){|f| f.fields_for(Asset.new, multipart: true){|ff| @f = ff } }
      render partial: 'artworks/asset_fields', locals: {object: Asset.new, f: @f, title: 'Title', text: 'Text', file_constraints: 'File constraints'}
      within_form_for Asset do
        expect(rendered).to have_selector("input#artwork_asset_file")
        expect(rendered).to have_selector("textarea#artwork_asset_description")
      end
    end
  end

  context 'asset exists already' do
    it 'displays the name of the file and an editable description field' do
      form_for(artwork, url: artworks_path(artwork)){|f| f.fields_for(assets, multipart: true){|ff| @f = ff } }
      render partial: 'artworks/asset_fields', locals: {object: assets, f: @f, title: 'Title', text: 'Text', file_constraints: 'File constraints'}
      within_form_for Asset do
        expect(rendered).to have_css("div", text: "#{assets.file_file_name}")
        expect(rendered).to have_selector("textarea#artwork_asset_description", text: "#{assets.description}")
      end
    end
  end

end
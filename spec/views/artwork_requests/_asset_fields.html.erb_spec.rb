require 'spec_helper'

describe 'artwork_requests/_asset_fields.html.erb', artwork_requests_spec: true do
  let!(:artwork_request){ build_stubbed(:blank_artwork_request) }
  let!(:order){ build_stubbed(:blank_order) }

  context 'no asset exists yet' do
    it 'displays the correct form fields for assets' do
      form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)){ |f| f.fields_for(Asset.new, multipart: true){ |ff| @f = ff } }
      render partial: 'artwork_requests/asset_fields', locals: { f: @f, object: Asset.new }
      within_form_for Asset do
        expect(rendered).to have_selector('input#artwork_request_asset_file')
        expect(rendered).to have_selector('textarea#artwork_request_asset_description')
        expect(rendered).to have_selector('input#artwork_request_asset__destroy')
        expect(rendered).to have_selector('a.js-remove-fields')
      end
    end
  end

  context 'asset exists already' do
    let!(:assets){ create(:valid_asset) }

    it 'displays the name of the file and an editable description field' do
      form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)){ |f| f.fields_for(assets, multipart: true){ |ff| @f = ff } }
      render partial: 'artwork_requests/asset_fields', locals: { f: @f, object: assets }
      within_form_for Asset do
        expect(rendered).to have_css('div', text: "#{assets.file_file_name}")
        expect(rendered).to have_selector('textarea#artwork_request_asset_description', text: "#{assets.description}")
        expect(rendered).to have_selector('input#artwork_request_asset__destroy')
        expect(rendered).to have_selector('a.js-remove-fields')
      end
    end
  end
end
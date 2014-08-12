require 'spec_helper'

describe 'artworks/_search.html.erb', artworks_spec: true do
  context 'no artwork_request exists and remote is false' do
    before(:each) do
      render partial: 'artworks/search', locals: { artwork_request: nil, remote: false }
    end

    it 'displays the search box and submit search button without passing any values to controller' do
        expect(rendered).to have_selector('input#search_artwork_fulltext')
        expect(rendered).to have_selector('input.submit')
        expect(rendered).to have_selector('input#locals_artwork_request_id[value]')
    end
  end

  context 'artwork_request exists and remote is true' do
    let!(:artwork_request){ build_stubbed(:valid_artwork_request) }
    let!(:artworks){ [build_stubbed(:valid_artwork)] }

    before(:each) do
      render partial: 'artworks/search', locals: { artwork_request: artwork_request, artworks: artworks, remote: true }
    end

    it 'displays the search box and submit search button and passes values to controller' do
      expect(rendered).to have_selector('input#search_artwork_fulltext')
      expect(rendered).to have_selector('input.submit')
      expect(rendered).to have_selector("input#locals_artwork_request_id[value='#{artwork_request.id}']")
    end
  end
end
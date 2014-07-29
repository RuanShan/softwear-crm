require 'spec_helper'

describe 'artworks/_search.html.erb', artworks_spec: true do

  context 'no artwork_request exists and remote is false' do
    before(:each) do
      render partial: 'artworks/search', locals: {remote: false, artwork_request: nil}
    end
    it 'displays the search box and submit search button without passing any values to controller' do
        expect(rendered).to have_selector("input#search_artwork_fulltext")
        expect(rendered).to have_selector("input.submit")
        expect(rendered).to have_selector("input#locals_artwork_request_id[value]")
    end
  end

  context 'artwork_request exists and remote is true' do
    let!(:artworks){ [create(:valid_artwork)] }
    let!(:artwork_request){ create(:valid_artwork_request) }

    before(:each) do
      render partial: 'artworks/search', locals: {remote: true, artwork_request: artwork_request, artworks: artworks}
    end
    it 'displays the search box and submit search button and passes values to controller' do
      expect(rendered).to have_selector("input#search_artwork_fulltext")
      expect(rendered).to have_selector("input.submit")
      expect(rendered).to have_selector("input#locals_artwork_request_id[value='#{artwork_request.id}']")
    end
  end
end
require 'spec_helper'

describe 'artworks/_row.html.erb', artwork_spec: true do
  let!(:artwork) { create(:valid_artwork, artist: create(:user)) }

  context 'given a single artwork and artwork_request is nil' do
    before(:each) do
      render partial: 'artworks/row', locals: { artwork: artwork, artwork_request: nil }
    end

    it 'has the artwork id, name, a thumbnail preview, a download file link, the tag list, the artists full name, the description, as well as
        buttons to edit, show, and destroy the artwork' do
      expect(rendered).to have_selector('td', text: "#{artwork.id}")
      expect(rendered).to have_selector('td', text: "#{artwork.name}")
      expect(rendered).to have_selector('td', text: "#{artwork.tag_list.join(', ')}")
      expect(rendered).to have_selector('td', text: "#{artwork.artist.full_name}")
      expect(rendered).to have_selector('td', text: "#{artwork.description}")
      expect(rendered).to have_selector("tr#artwork-row-#{artwork.id}")
      expect(rendered).to have_selector("img[src='#{artwork.preview.file.url(:thumb)}']")

      expect(artwork.artwork.file.url).to_not be_nil

      expect(rendered).to have_selector("a[href='#{artwork.artwork.file.url}']")
      expect(rendered).to have_selector("a[href='#{edit_artwork_path(artwork)}']")
      expect(rendered).to have_selector("a[href='#{artwork_path(artwork)}?disable_buttons=true']")
      expect(rendered).to have_selector("a[href='#{artwork_path(artwork)}']")
    end
  end

  context 'artwork_request is not nil but not associated with artwork' do
    let!(:artwork_request) { build_stubbed(:blank_artwork_request) }

    before(:each) do
      render partial: 'artworks/row', locals: { artwork: artwork, artwork_request: artwork_request }
    end

    it 'has a button to add the artwork to the artwork_request' do
      expect(rendered).to have_selector("a[href='#{artwork_request_path(id: artwork_request.id, artwork_id: artwork.id)}']")
    end
  end

  context 'artwork_request is not nil and associated with artwork' do
    let!(:artwork_request) { build_stubbed(:blank_artwork_request, artworks: [build_stubbed(:blank_artwork, artist: build_stubbed(:blank_user))]) }
    let!(:artwork) { artwork_request.artworks.first }

    before(:each) do
      render partial: 'artworks/row', locals: { artwork: artwork, artwork_request: artwork_request }
    end

    it 'has text saying that the artwork has already been added to artwork request' do
      expect(rendered).to have_selector('span', text: 'Already Added')
    end
  end
end

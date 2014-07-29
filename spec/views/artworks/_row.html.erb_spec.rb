require 'spec_helper'

describe 'artworks/_row.html.erb', artworks_spec: true do

  context 'artwork_request is nil' do
    let!(:artwork){ create(:valid_artwork) }
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
      expect(rendered).to have_selector("a[href='#{artwork.artwork.file.url}']")
      expect(rendered).to have_selector("a[href='#{edit_artwork_path(artwork)}']")
      expect(rendered).to have_selector("a[href='#{artwork_path(artwork)}?disable_buttons=true']")
      expect(rendered).to have_selector("a[href='#{artwork_path(artwork)}']")
    end

    it 'should render _row.html.erb for every artwork, regardless of artwork_request being defined' do
      expect(rendered).to render_template(partial: '_row')
    end
  end

  context 'artwork_request is not nil but not associated with artwork' do
    let!(:artwork){ create(:valid_artwork) }
    let!(:artwork_request){ create(:valid_artwork_request) }
    before(:each) do
      render partial: 'artworks/row', locals: { artwork: artwork, artwork_request: artwork_request }
    end

    it 'has the artwork id, name, a thumbnail preview, a download file link, the tag list, the artists full name, the description, as well as
        a button to add the artwork to the artwork_request' do
      expect(rendered).to have_selector('td', text: "#{artwork.id}")
      expect(rendered).to have_selector('td', text: "#{artwork.name}")
      expect(rendered).to have_selector('td', text: "#{artwork.tag_list.join(', ')}")
      expect(rendered).to have_selector('td', text: "#{artwork.artist.full_name}")
      expect(rendered).to have_selector('td', text: "#{artwork.description}")
      expect(rendered).to have_selector("tr#artwork-row-#{artwork.id}")
      expect(rendered).to have_selector("img[src='#{artwork.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{artwork.artwork.file.url}']")
      expect(rendered).to have_selector("a[href='#{artwork_request_path(id: artwork_request.id, artwork_id: artwork.id)}']")
    end

    it 'should render _row.html.erb for every artwork, regardless of artwork_request being defined' do
      expect(rendered).to render_template(partial: '_row')
    end
  end

  context 'artwork_request is not nil and associated with artwork' do
    let!(:artwork_request){ create(:valid_artwork_request_with_artwork) }
    let!(:artwork){ artwork_request.artworks.first }
    before(:each) do
      render partial: 'artworks/row', locals: { artwork: artwork_request.artworks.first, artwork_request: artwork_request }
    end

    it 'has the artwork id, name, a thumbnail preview, a download file link, the tag list, the artists full name, the description, as well as
        text saying that the artwork has already been added to artwork request' do
      expect(rendered).to have_selector('td', text: "#{artwork.id}")
      expect(rendered).to have_selector('td', text: "#{artwork.name}")
      expect(rendered).to have_selector('td', text: "#{artwork.tag_list.join(', ')}")
      expect(rendered).to have_selector('td', text: "#{artwork.artist.full_name}")
      expect(rendered).to have_selector('td', text: "#{artwork.description}")
      expect(rendered).to have_selector("tr#artwork-row-#{artwork.id}")
      expect(rendered).to have_selector("img[src='#{artwork.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{artwork.artwork.file.url}']")
      expect(rendered).to have_selector('span', text: 'Already Added')
    end

    it 'should render _row.html.erb for every artwork, regardless of artwork_request being defined' do
      expect(rendered).to render_template(partial: '_row')
    end
  end
end
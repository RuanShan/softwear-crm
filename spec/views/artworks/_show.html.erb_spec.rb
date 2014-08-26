require 'spec_helper'

describe 'artworks/_show.html.erb', artwork_spec: true do
  let!(:artwork) { build_stubbed(:blank_artwork, artist: build_stubbed(:blank_user)) }

  before(:each) do
    render partial: 'artworks/show', locals: {artwork: artwork}
  end

  it 'renders the artworks preview file, description, tags, artist, a link to download the artwork file, and a link to enlarge the preview file' do
    expect(rendered).to have_selector("img[src='#{artwork.preview.file.url(:medium)}']")
    expect(rendered).to include("#{artwork.description}")
    expect(rendered).to include("#{artwork.tag_list.join(', ')}")
    expect(rendered).to include("#{artwork.artist.full_name}")
    expect(rendered).to have_selector("a[href='#{artwork.artwork.file.url}']")
    expect(rendered).to include("(#{number_to_human_size(artwork.artwork.file_file_size)})")
    expect(rendered).to have_selector("a[href='#{artwork.preview.file.url}']")
  end
end
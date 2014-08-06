require 'spec_helper'

describe 'artwork_requests/_artworks.html.erb', artwork_requests_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request_with_artwork) }
  before(:each) do
    render partial: 'artwork_requests/artworks', locals: {artwork_request: artwork_request}
  end
  it 'displays the fields for an artwork attached to an artwork request', slow: true do
    expect(rendered).to have_selector("h4.artwork-title")
    expect(rendered).to have_css("dt", text: 'Name:')
    expect(rendered).to have_css("dd", text: "#{artwork_request.artworks.first.name}")
    expect(rendered).to have_selector("img[src='#{artwork_request.artworks.first.preview.file.url(:medium)}']")
    expect(rendered).to have_selector("a[href='#{artwork_request_path(id: artwork_request.id, remove_artwork: true, artwork_id: artwork_request.artworks.first.id)}']")
    expect(rendered).to have_css("dt", text: 'Created By:')
    expect(rendered).to have_css("dd", text: "#{artwork_request.artworks.first.artist.full_name}")
    expect(rendered).to have_css("dt", text: 'Description:')
    expect(rendered).to have_css("dd", text: "#{artwork_request.artworks.first.description}")
  end
end

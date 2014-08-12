require 'spec_helper'

describe 'artworks/_artwork_request.html.erb', artwork_spec: true do
  let!(:artwork_request){ build_stubbed(:blank_artwork_request) }
  let!(:artworks){ [build_stubbed(:blank_artwork, artist: build_stubbed(:blank_user))] }

  before(:each) do
    render partial: 'artworks/search', locals: { artwork_request: artwork_request, artworks: artworks, remote: true  }
    render partial: 'artworks/table', locals: { artwork_request: artwork_request, artworks: artworks }
  end

  it 'renders _table.html.erb and _search.html.erb' do
    expect(rendered).to render_template(partial: '_table')
    expect(rendered).to render_template(partial: '_search')
  end
end
require 'spec_helper'

describe 'artworks/_artwork_request.html.erb', artworks_spec: true do
  let!(:artworks){ [create(:valid_artwork)] }
  let!(:artwork_request){ create(:valid_artwork_request) }

  before(:each) do
    render partial: 'artworks/search', locals: {remote: true, artworks: artworks, artwork_request: artwork_request}
    render partial: 'artworks/table', locals: {artworks: artworks, artwork_request: artwork_request}
  end

  it 'renders _table.html.erb and _search.html.erb' do
    expect(rendered).to render_template(partial: '_table')
    expect(rendered).to render_template(partial: '_search')
  end

end
require 'spec_helper'

describe 'artworks/index.html.erb', artworks_spec: true do
  let!(:artworks){ [create(:valid_artwork)] }

  it 'renders _table.html.erb and _search.html.erb' do
    assign(:artwork_request, nil)
    assign(:artworks, Artwork.all.page)
    assign(:remote, false)
    render
    expect(rendered).to render_template(partial: '_table')
    expect(rendered).to render_template(partial: '_search')
  end

end
require 'spec_helper'

describe 'artwork_requests/index.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { create(:valid_artwork_request) }
  let!(:current_user) { User.where(id: artwork_request.artist_id).first }

  it 'renders _table.html.erb' do
    allow(view).to receive(:current_user).and_return(current_user)
    assign(:artwork_requests, ArtworkRequest.all.page(1))
    render
    expect(rendered).to render_template(partial: '_table')
  end
end

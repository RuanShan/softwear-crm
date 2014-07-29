require 'spec_helper'

describe 'artwork_requests/index.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }

  it 'renders _table.html.erb' do
    assign(:artwork_requests, ArtworkRequest.all)
    assign(:current_user, create(:user))
    render
    expect(rendered).to render_template(partial: '_table')
  end
end
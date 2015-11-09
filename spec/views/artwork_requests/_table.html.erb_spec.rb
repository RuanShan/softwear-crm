require 'spec_helper'

describe 'artwork_requests/_table.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { create(:valid_artwork_request) }
  let!(:current_user) { User.where(id: artwork_request.artist_id).first }

  before(:each) do
    render partial: 'artwork_requests/table', locals: { artwork_requests: ArtworkRequest.all, current_user: current_user }
  end

  it 'has table with priority, artwork request deadline, order in hand by date,
      imprint method, no. of pieces, ink color count, payment status, order name, and actions columns' do
    expect(rendered).to have_selector('th', text: 'Priority')
    expect(rendered).to have_selector('th', text: 'Order Details')
    expect(rendered).to have_selector('th', text: 'Request Details')
    expect(rendered).to have_selector('th', text: 'Artwork Request Deadline')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'renders _row.html.erb for every artwork_request where the artist_id is the same as the current_user id' do
    expect(rendered).to render_template(partial: '_row')
  end
end

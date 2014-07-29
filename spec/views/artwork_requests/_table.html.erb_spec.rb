require 'spec_helper'

describe 'artwork_requests/_table.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }

  before(:each) do
    assign(:current_user, User.where(id: artwork_request.artist_id).first)
    render partial: 'artwork_requests/table', locals: { artwork_requests: ArtworkRequest.all  }
  end

  it 'has table with priority, hard deadline, proof deadline, imprint method, quantity, payment terms, and order name columns' do
    expect(rendered).to have_selector('th', text: 'Priority')
    expect(rendered).to have_selector('th', text: 'Artwork Request Deadline')
    expect(rendered).to have_selector('th', text: 'Order In Hand By Date')
    expect(rendered).to have_selector('th', text: 'Imprint Method')
    expect(rendered).to have_selector('th', text: 'No. of Pieces')
    expect(rendered).to have_selector('th', text: 'Ink Color Count')
    expect(rendered).to have_selector('th', text: 'Payment Status')
    expect(rendered).to have_selector('th', text: 'Order Name')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'should render _row.html.erb for every artwork_request where the artist_id is the same as the current_user id' do
    expect(rendered).to render_template(partial: '_row')
  end

end
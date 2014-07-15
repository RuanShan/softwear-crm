require 'spec_helper'

describe 'artwork_requests/_table.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }

  it 'has table with priority, hard deadline, proof deadline, imprint method, quantity, payment terms, and order name columns' do
    render partial: 'artwork_requests/table', locals: { artwork_requests: ArtworkRequest.all, current_user: create(:user) }
    expect(rendered).to have_selector('th', text: 'Priority')
    expect(rendered).to have_selector('th', text: 'Artwork Request Deadline')
    expect(rendered).to have_selector('th', text: 'Order In Hand By Date')
    expect(rendered).to have_selector('th', text: 'Imprint Method')
    expect(rendered).to have_selector('th', text: 'No. of Pieces')
    expect(rendered).to have_selector('th', text: 'Ink Color Count')
    expect(rendered).to have_selector('th', text: 'Payment Status')
    expect(rendered).to have_selector('th', text: 'Order Name')
    expect(rendered).to have_selector('th', text: 'Edit/Show')
  end

  it 'should render _row.html.erb for every artwork_request' do

  end

end
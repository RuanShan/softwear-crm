require 'spec_helper'

describe 'artwork_requests/_table.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }

  it 'has table with priority, hard deadline, proof deadline, imprint method, quantity, payment terms, and order name columns' do
    render partial: 'artwork_requests/table', locals: { artwork_requests: ArtworkRequest.all, current_user: create(:user) }
    expect(rendered).to have_selector('th', text: 'Priority')
    expect(rendered).to have_selector('th', text: 'Hard Deadline')
    expect(rendered).to have_selector('th', text: 'Proof Deadline')
    expect(rendered).to have_selector('th', text: 'Imprint Method')
    expect(rendered).to have_selector('th', text: 'Quantity')
    expect(rendered).to have_selector('th', text: 'Payment Terms')
    expect(rendered).to have_selector('th', text: 'Order Name')
  end

  it 'should render _row.html.erb for every artwork_request' do

  end

end
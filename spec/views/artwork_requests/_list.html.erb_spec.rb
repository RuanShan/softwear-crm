require 'spec_helper'

describe 'artwork_requests/_list.html.erb', artwork_requests_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:order){ create(:order_with_job)}
  let!(:user){ create(:user)}

  before(:each) do
    current_user = build_stubbed(:blank_user)
    allow(current_user).to receive(:full_name).and_return('Stone Cold Steve Austin')
    allow(view).to receive(:current_user).and_return(current_user)
    render partial: 'artwork_requests/list', locals: { order: order, artwork_request: artwork_request }
  end

  it 'has a div to contain all artwork_requests' do
    expect(rendered).to have_selector("div.artwork-request-list")
  end

  it 'has a button to add artwork requests' do
    expect(rendered).to have_selector("a#new_artwork_request")
  end
end
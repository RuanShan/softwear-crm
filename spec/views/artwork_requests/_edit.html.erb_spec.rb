require 'spec_helper'

describe 'artwork_requests/_edit.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:order){ create(:order_with_job)}
  let!(:user){ create(:user)}

  before(:each) do
    allow(view).to receive(:current_user).and_return(user)
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)){|f| @f = f }
    render partial: 'artwork_requests/edit', locals: {order: order, artwork_request: artwork_request, f: @f}
  end

  it 'has a create artwork request button' do
    expect(rendered).to have_selector("input[type='submit']")
    expect(rendered).to have_selector("input[value='Update Artwork Request']")
  end

  it 'renders partial form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end

end
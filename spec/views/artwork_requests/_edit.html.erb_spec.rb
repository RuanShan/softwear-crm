require 'spec_helper'

describe 'artwork_requests/_edit.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { build_stubbed(:blank_artwork_request) }
  let!(:order) { build_stubbed(:blank_order) }

  before(:each) do
    current_user = build_stubbed(:blank_user)
    allow(current_user).to receive(:full_name).and_return('Stone Cold Steve Austin')
    allow(view).to receive(:current_user).and_return(current_user)
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)) { |f| @f = f }
    render 'artwork_requests/edit', { artwork_request: artwork_request, order: order }
  end

  it 'renders partial form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end
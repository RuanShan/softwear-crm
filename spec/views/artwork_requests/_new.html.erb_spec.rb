require 'spec_helper'

describe 'artwork_requests/_new.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { build_stubbed(:blank_artwork_request) }
  let!(:order) { build_stubbed(:blank_order) }

  before(:each) do
    allow(view).to receive(:current_user).and_return(build_stubbed(:blank_user))
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)) { |f| @f = f }
    render 'artwork_requests/new', { artwork_request: ArtworkRequest.new, f: @f, order: order }
  end
  
  it 'renders partial form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end
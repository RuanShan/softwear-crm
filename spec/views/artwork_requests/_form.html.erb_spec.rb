require 'spec_helper'

describe 'artwork_requests/_form.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { build_stubbed(:blank_artwork_request) }
  let!(:order) { build_stubbed(:blank_order) }

  it 'displays the correct form fields for artwork_requests' do
    allow(artwork_request).to receive(:new_record?).and_return false
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)) { |f| @f = f }
    render partial: 'artwork_requests/form', locals: { artwork_request: artwork_request, current_user: build_stubbed(:blank_user), f: @f, order: order }
    within_form_for ArtworkRequest do
      expect(rendered).to have_selector('select#artwork_request_imprint_ids')
      expect(rendered).to have_selector('select#artwork_request_priority')
      expect(rendered).to have_selector('select#artwork_request_state')
      expect(rendered).to have_selector('input#artwork_request_deadline')
      expect(rendered).to have_selector('i.artwork-assets')
    end
  end

  it 'renders an artist select box when the artwork request is not new', story_939: true do
    allow(artwork_request).to receive(:new_record?).and_return false
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)) { |f| @f = f }
    render partial: 'artwork_requests/form', locals: { artwork_request: artwork_request, current_user: build_stubbed(:blank_user), f: @f, order: order }
    expect(rendered).to have_selector('select#artwork_request_artist_id')
  end

  it 'does not render an artist select box when the artwork request is new', story_939: true do
    allow(artwork_request).to receive(:new_record?).and_return true
    form_for(artwork_request, url: order_artwork_requests_path(order, artwork_request)) { |f| @f = f }
    render partial: 'artwork_requests/form', locals: { artwork_request: artwork_request, current_user: build_stubbed(:blank_user), f: @f, order: order }
    expect(rendered).to_not have_selector('select#artwork_request_artist_id')
  end
end

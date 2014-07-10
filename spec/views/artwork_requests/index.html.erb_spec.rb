require 'spec_helper'

describe 'imprintables/index.html.erb', imprintable_spec: true, new: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  before(:each) do
    render partial: 'artwork_requests/table', locals: {artwork_requests: ArtworkRequest.all, current_user: create(:user)}
  end
  it 'renders _table.html.erb' do
    expect(rendered).to render_template(partial: '_table')
  end
end
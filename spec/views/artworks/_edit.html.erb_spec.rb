require 'spec_helper'

describe 'artworks/_edit.html.erb', artworks_spec: true do
  let!(:artwork){ create(:valid_artwork) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  before(:each) do
    render partial: 'artworks/edit', locals: {artwork: artwork}
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end

end
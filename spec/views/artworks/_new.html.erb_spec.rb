require 'spec_helper'

describe 'artworks/_new.html.erb', artworks_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  before(:each) do
    render partial: 'artworks/new', locals: {artwork: Artwork.new}
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end

end
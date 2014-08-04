require 'spec_helper'

describe 'artworks/_new.html.erb', artworks_spec: true do
  let!(:current_user){ create(:user) }

  before(:each) do
    allow(view).to receive(:current_user).and_return(current_user)
    render partial: 'artworks/new', locals: {artwork: Artwork.new, current_user: current_user}
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end

end
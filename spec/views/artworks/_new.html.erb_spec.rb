require 'spec_helper'

describe 'artworks/_new.html.erb', artworks_spec: true do
  before(:each) do
    allow(view).to receive(:current_user).and_return(build_stubbed(:blank_user))
    render partial: 'artworks/new', locals: { artwork: build_stubbed(:blank_artwork) }
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end
require 'spec_helper'

describe 'artworks/_edit.html.erb', artworks_spec: true do
  let!(:artwork){ build_stubbed(:blank_artwork) }

  before(:each) do
    current_user = build_stubbed(:blank_user)
    allow(view).to receive(:current_user).and_return(current_user)
    render partial: 'artworks/edit', locals: { artwork: artwork }
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end
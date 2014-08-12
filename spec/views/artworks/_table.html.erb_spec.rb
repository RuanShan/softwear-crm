require 'spec_helper'

describe 'artworks/_table.html.erb', artwork_spec: true do
  let!(:artworks){ [build_stubbed(:blank_artwork, artist: build_stubbed(:blank_user))] }

  before(:each) do
    render partial: 'artworks/table', locals: { artworks: artworks }
  end

  it 'has table with id, name, artwork, art file, tags, created by, description, and actions' do
    expect(rendered).to have_selector('th', text: 'ID')
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Artwork')
    expect(rendered).to have_selector('th', text: 'Art File')
    expect(rendered).to have_selector('th', text: 'Tags')
    expect(rendered).to have_selector('th', text: 'Created By')
    expect(rendered).to have_selector('th', text: 'Description')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'should render _row.html.erb for every artwork, regardless of artwork_request being defined' do
    expect(rendered).to render_template(partial: '_row')
  end
end
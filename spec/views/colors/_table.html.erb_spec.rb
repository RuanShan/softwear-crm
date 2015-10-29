require 'spec_helper'

describe 'colors/_table.html.erb', color_spec: true do

  let!(:colors) { [build_stubbed(:valid_color, map: 'Blorange')] }

  before(:each) { render partial: 'colors/table', locals: { colors: colors } }

  it 'has table with header for name, sku, and map' do
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Map')
    expect(rendered).to have_selector('th', text: 'SKU')
  end

  it 'has a table with the color\'s name, sku, and map' do
    expect(rendered).to have_selector('td', text: colors.first.name)
    expect(rendered).to have_selector('td', text: colors.first.map)
    expect(rendered).to have_selector('td', text: colors.first.sku)
  end

  it 'has a button to destroy and edit the color' do
    expect(rendered).to have_selector("tr#color_#{colors.first.id} td a[href='#{color_path(colors.first)}']")
    expect(rendered).to have_selector("tr#color_#{colors.first.id} td a[href='#{edit_color_path(colors.first)}']")
  end
end

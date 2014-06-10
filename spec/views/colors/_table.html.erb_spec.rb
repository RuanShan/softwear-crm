require 'spec_helper'

describe 'colors/_table.html.erb', color_spec: true do

  let!(:colors) do
    [create(:valid_color)]
    assign(:colors, Color.all)
  end

  it 'has table with name and sku columns' do
    render partial: 'colors/table', locals: {colors: colors}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Stock Keeping Unit')
  end

  it 'displays the name and sku of that color' do
    render partial: 'colors/table', locals: {colors: colors}
    expect(rendered).to have_selector('td', text: colors.first.name)
    expect(rendered).to have_selector('td', text: colors.first.sku)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'colors/table', locals: {colors: colors}
    expect(rendered).to have_selector("tr#color_#{colors.first.id} td a[href='#{color_path(colors.first)}']")
    expect(rendered).to have_selector("tr#color_#{colors.first.id} td a[href='#{edit_color_path(colors.first)}']")
  end
end
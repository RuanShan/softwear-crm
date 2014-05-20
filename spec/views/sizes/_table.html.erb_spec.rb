require 'spec_helper'

describe 'sizes/_table.html.erb' do

  let!(:sizes) do
    [create(:valid_size)]
    assign(:sizes, Size.all)
  end

  it 'has table with name, display_value, sku and sort order columns' do
    render partial: 'sizes/table', locals: {sizes: sizes}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Display Value')
    expect(rendered).to have_selector('th', text: 'Stock Keeping Unit')
    expect(rendered).to have_selector('th', text: 'Sort Order')
  end

  it 'displays the name, display_value, sku and sort order of that size' do
    render partial: 'sizes/table', locals: {sizes: sizes}
    expect(rendered).to have_selector('td', text: sizes.first.name)
    expect(rendered).to have_selector('td', text: sizes.first.display_value)
    expect(rendered).to have_selector('td', text: sizes.first.sku)
    expect(rendered).to have_selector('td', text: sizes.first.sort_order)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'sizes/table', locals: {sizes: sizes}
    expect(rendered).to have_selector("tr#size_#{sizes.first.id} td a[href='#{size_path(sizes.first)}']")
    expect(rendered).to have_selector("tr#size_#{sizes.first.id} td a[href='#{edit_size_path(sizes.first)}']")
  end
end
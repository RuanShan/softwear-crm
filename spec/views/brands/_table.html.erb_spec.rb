require 'spec_helper'

describe 'brands/_table.html.erb', brand_spec: true do

  let!(:brands) do
    [create(:valid_brand)]
    assign(:brands, Brand.all)
  end

  it 'has table with name and sku columns' do
    render partial: 'brands/table', locals: {brands: brands}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Stock Keeping Unit')
  end

  it 'displays the name and sku of that brand' do
    render partial: 'brands/table', locals: {brands: brands}
    expect(rendered).to have_selector('td', text: brands.first.name)
    expect(rendered).to have_selector('td', text: brands.first.sku)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'brands/table', locals: {brands: brands}
    expect(rendered).to have_selector("tr#brand_#{brands.first.id} td a[href='#{brand_path(brands.first)}']")
    expect(rendered).to have_selector("tr#brand_#{brands.first.id} td a[href='#{edit_brand_path(brands.first)}']")
  end
end

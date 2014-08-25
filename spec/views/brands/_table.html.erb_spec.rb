require 'spec_helper'

describe 'brands/_table.html.erb', brand_spec: true do

  let!(:brands) do
    assign(:brands, [build_stubbed(:valid_brand)])
  end

  before(:each) { render partial: 'brands/table', locals: { brands: brands } }

  it 'has table with name and sku' do
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'SKU')
  end

  it 'displays the information of the brand' do
    expect(rendered).to have_selector('td', text: brands.first.name)
    expect(rendered).to have_selector('td', text: brands.first.sku)
  end

  it 'has an actions column with a link to edit and destroy' do
    expect(rendered).to have_selector("tr#brand_#{brands.first.id} td a[href='#{brand_path(brands.first)}']")
    expect(rendered).to have_selector("tr#brand_#{brands.first.id} td a[href='#{edit_brand_path(brands.first)}']")
  end
end

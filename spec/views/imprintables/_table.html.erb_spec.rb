require 'spec_helper'

describe 'imprintables/_table.html.erb', imprintable_spec: true do
  let!(:imprintables) do
    [create(:valid_imprintable)]
    assign(:imprintables, Imprintable.all)
  end

  it 'has table with name, catalog number, description, material, sizing category, brand, style, flashable, polyester, and special consideration columns' do
    render partial: 'imprintables/table', locals: { imprintables: imprintables }
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Catalog Number')
    expect(rendered).to have_selector('th', text: 'Description')
    expect(rendered).to have_selector('th', text: 'Material')
    expect(rendered).to have_selector('th', text: 'Proofing Template Name')
    expect(rendered).to have_selector('th', text: 'Sizing Category')
    expect(rendered).to have_selector('th', text: 'Brand')
    expect(rendered).to have_selector('th', text: 'Style')
    expect(rendered).to have_selector('th', text: 'Tags')
    expect(rendered).to have_selector('th', text: 'Flashable?')
    expect(rendered).to have_selector('th', text: 'Polyester?')
    expect(rendered).to have_selector('th', text: 'Special Considerations')
    expect(rendered).to have_selector('th', text: 'Standard Offering')
  end

  it 'displays the name, catalog number, and description material, sizing category, brand, style, flashable, polyester, and special consideration of that imprintable' do
    render partial: 'imprintables/table', locals: { imprintables: imprintables }
    expect(rendered).to have_selector('td', text: imprintables.first.name)
    expect(rendered).to have_selector('td', text: imprintables.first.style.catalog_no)
    expect(rendered).to have_selector('td', text: imprintables.first.style.description)
    expect(rendered).to have_selector('td', text: imprintables.first.description)
    expect(rendered).to have_selector('td', text: imprintables.first.material)
    expect(rendered).to have_selector('td', text: imprintables.first.sizing_category)
    expect(rendered).to have_selector('td', text: imprintables.first.brand.name)
    expect(rendered).to have_selector('td', text: imprintables.first.style.name)
    expect(rendered).to have_selector('td', text: imprintables.first.tag_list)
    expect(rendered).to have_selector('td', text: imprintables.first.flashable)
    expect(rendered).to have_selector('td', text: imprintables.first.polyester)
    expect(rendered).to have_selector('td', text: imprintables.first.special_considerations)
    expect(rendered).to have_selector('td', text: imprintables.first.standard_offering)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'imprintables/table', locals: { imprintables: imprintables }
    expect(rendered).to have_selector("tr#imprintable_#{imprintables.first.id} td a[href='#{imprintable_path(imprintables.first)}']")
    expect(rendered).to have_selector("tr#imprintable_#{imprintables.first.id} td a[href='#{edit_imprintable_path(imprintables.first)}']")
  end
end

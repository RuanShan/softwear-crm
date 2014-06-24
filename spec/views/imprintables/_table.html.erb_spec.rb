require 'spec_helper'

describe 'imprintables/_table.html.erb', imprintable_spec: true do
  let!(:imprintables) do
    [create(:valid_imprintable)]
    assign(:imprintables, Imprintable.all)
  end

  it 'has table with name, catalog number, description, material, sizing category, brand, style, flashable, polyester, and special consideration columns' do
    render partial: 'imprintables/table', locals: { imprintables: imprintables }
    expect(rendered).to have_selector('th', text: 'Standard Offering')
    expect(rendered).to have_selector('th', text: 'Imprintable')
    expect(rendered).to have_selector('th', text: 'Description')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'displays the name, catalog number, and description material, sizing category, brand, style, flashable, polyester, and special consideration of that imprintable', pending: true do
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

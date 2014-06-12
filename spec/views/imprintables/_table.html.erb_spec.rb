require 'spec_helper'

describe 'imprintables/_table.html.erb', imprintable_spec: true do
  let!(:imprintables) do
    [create(:valid_imprintable)]
    assign(:imprintables, Imprintable.all)
  end

  it 'has table with name, catalog number, description columns' do
    render partial: 'imprintables/table', locals: {imprintables: imprintables}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Catalog Number')
    expect(rendered).to have_selector('th', text: 'Description')
  end

  it 'displays the name, catalog number, and description of that imprintable' do
    render partial: 'imprintables/table', locals: {imprintables: imprintables}
    expect(rendered).to have_selector('td', text: imprintables.first.name)
    expect(rendered).to have_selector('td', text: imprintables.first.style.catalog_no)
    expect(rendered).to have_selector('td', text: imprintables.first.style.description)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'imprintables/table', locals: {imprintables: imprintables}
    expect(rendered).to have_selector("tr#imprintable_#{imprintables.first.id} td a[href='#{imprintable_path(imprintables.first)}']")
    expect(rendered).to have_selector("tr#imprintable_#{imprintables.first.id} td a[href='#{edit_imprintable_path(imprintables.first)}']")
  end
end

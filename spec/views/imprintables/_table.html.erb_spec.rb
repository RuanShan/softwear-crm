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

  it 'displays the name, description' do
    render partial: 'imprintables/table', locals: { imprintables: imprintables }
    expect(rendered).to have_selector('td', text: imprintables.first.name)
    expect(rendered).to have_selector('td', text: imprintables.first.description)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'imprintables/table', locals: { imprintables: imprintables }
    expect(rendered).to have_selector("tr#imprintable_#{imprintables.first.id} td a[href='#{imprintable_path(imprintables.first)}']")
    expect(rendered).to have_selector("tr#imprintable_#{imprintables.first.id} td a[href='#{edit_imprintable_path(imprintables.first)}']")
  end

  context 'an imprintable is a standard offering' do
    it 'displays a check mark in the row' do
      imprintables.first.update_attribute(:standard_offering, true)
      render partial: 'imprintables/table', locals: { imprintables: imprintables }
      expect(rendered).to have_selector('i.fa-check-square')
    end
  end
end

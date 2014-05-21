require 'spec_helper'

describe 'styles/_table.html.erb' do

  let!(:styles) do
    [create(:valid_style)]
    assign(:styles, Style.all)
  end

  it 'has table with name, catalog_no, description, and sku columns' do
    render partial: 'styles/table', locals: {styles: styles}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Catalog Number')
    expect(rendered).to have_selector('th', text: 'Description')
    expect(rendered).to have_selector('th', text: 'Stock Keeping Unit')
  end

  it 'displays the name, catalog_no, description, and sku of that style' do
    render partial: 'styles/table', locals: {styles: styles}
    expect(rendered).to have_selector('td', text: styles.first.name)
    expect(rendered).to have_selector('td', text: styles.first.catalog_no)
    expect(rendered).to have_selector('td', text: styles.first.description)
    expect(rendered).to have_selector('td', text: styles.first.sku)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'styles/table', locals: {styles: styles}
    expect(rendered).to have_selector("tr#style_#{styles.first.id} td a[href='#{style_path(styles.first)}']")
    expect(rendered).to have_selector("tr#style_#{styles.first.id} td a[href='#{edit_style_path(styles.first)}']")
  end
end
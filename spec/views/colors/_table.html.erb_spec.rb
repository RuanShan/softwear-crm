require 'spec_helper'

describe 'colors/_table.html.erb', color_spec: true do

  let!(:colors){ [build_stubbed(:valid_color)] }

  before(:each){ render partial: 'colors/table', locals: { colors: colors } }

  it 'has table with name, sku, and action columns' do
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'SKU')
    expect(rendered).to have_selector('td', text: colors.first.name)
    expect(rendered).to have_selector('td', text: colors.first.sku)
    expect(rendered).to have_selector("tr#color_#{colors.first.id} td a[href='#{color_path(colors.first)}']")
    expect(rendered).to have_selector("tr#color_#{colors.first.id} td a[href='#{edit_color_path(colors.first)}']")
  end
end
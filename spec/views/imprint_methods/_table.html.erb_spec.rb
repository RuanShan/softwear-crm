require 'spec_helper'

describe 'imprint_methods/_table.html.erb', imprint_method_spec: true do

  let(:imprint_methods){ [create(:valid_imprint_method_with_color_and_location)] }

  it 'has a table with the name, ink colors, and actions' do
    render partial: 'imprint_methods/table', locals: {imprint_methods: imprint_methods}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Ink Colors')
    expect(rendered).to have_selector('th', text: 'Print Locations')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'displays the name and ink colors' do
    render partial: 'imprint_methods/table', locals: {imprint_methods: imprint_methods}
    expect(rendered).to have_selector('td', text: imprint_methods.first.name)
    expect(rendered).to have_selector('td', text: imprint_methods.first.ink_colors.first.name)
    expect(rendered).to have_selector('td', text: imprint_methods.first.print_locations.first.name)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'imprint_methods/table', locals: {imprint_methods: imprint_methods}
    expect(rendered).to have_selector("tr#imprint_method_#{imprint_methods.first.id} td a[href='#{edit_imprint_method_path(imprint_methods.first)}']")
    expect(rendered).to have_selector("tr#imprint_method_#{imprint_methods.first.id} td a[href='#{imprint_method_path(imprint_methods.first)}']")
  end
end
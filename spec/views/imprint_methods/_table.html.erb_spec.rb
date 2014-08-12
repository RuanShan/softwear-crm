require 'spec_helper'

describe 'imprint_methods/_table.html.erb', imprint_methods_spec: true do

  let(:imprint_methods){ [build_stubbed(:blank_imprint_method,
                                          ink_colors: [build_stubbed(:blank_ink_color)],
                                          print_locations: [build_stubbed(:blank_print_location)])] }

  it 'has a table with the name, ink colors, and actions' do
    render partial: 'imprint_methods/table', locals: { imprint_methods: imprint_methods }
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Ink Colors')
    expect(rendered).to have_selector('th', text: 'Print Locations')
    expect(rendered).to have_selector('th', text: 'Actions')
    expect(rendered).to have_selector('td', text: imprint_methods.first.name)
    expect(rendered).to have_selector('td', text: imprint_methods.first.ink_colors.first.name)
    expect(rendered).to have_selector('td', text: imprint_methods.first.print_locations.first.name)
    expect(rendered).to have_selector("tr#imprint_method_#{imprint_methods.first.id} td a[href='#{edit_imprint_method_path(imprint_methods.first)}']")
    expect(rendered).to have_selector("tr#imprint_method_#{imprint_methods.first.id} td a[href='#{imprint_method_path(imprint_methods.first)}']")
  end
end
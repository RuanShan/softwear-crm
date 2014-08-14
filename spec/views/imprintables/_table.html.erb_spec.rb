require 'spec_helper'

describe 'imprintables/_table.html.erb', imprintable_spec: true do
  let!(:imprintable) { build_stubbed(:valid_imprintable) }
  let!(:imprintables) { assign(:imprintables, [imprintable]) }

  before(:each) do
    allow(imprintable).to receive(:name).and_return 'name'
    render partial: 'imprintables/table',
           locals: { imprintables: imprintables }
  end

  it 'has table with name, catalog number, description, material, sizing category,
      brand, style, flashable, polyester, and special consideration columns' do
    expect(rendered).to have_selector('th', text: 'Standard Offering')
    expect(rendered).to have_selector('th', text: 'Imprintable')
    expect(rendered).to have_selector('th', text: 'Description')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'displays the name, description' do
    expect(rendered).to have_selector('td', text: imprintable.name)
    expect(rendered).to have_selector('td', text: imprintable.description)
  end

  it 'actions column has a link to edit and a link to destroy' do
    expect(rendered).to have_selector("tr#imprintable_#{imprintable.id}
                                       td a[href='#{imprintable_path(imprintable)}']")
    expect(rendered).to have_selector("tr#imprintable_#{imprintable.id}
                                       td a[href='#{edit_imprintable_path(imprintable)}']")
  end

  context 'the imprintable is a standard offering' do
    before(:each) do
      allow(imprintable).to receive(:standard_offering?).and_return true
      render partial: 'imprintables/table',
             locals: { imprintables: imprintables }
    end
    it 'displays a check mark that the imprintable is a standard offering' do
      expect(rendered).to have_selector('i.fa-check-square')
    end
  end
end

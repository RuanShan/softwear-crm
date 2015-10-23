require 'spec_helper'

describe 'stores/_table.html.erb', store_spec: true do
  let!(:stores) { [build_stubbed(:valid_store)] }

  before(:each) do
    assign(:stores, stores)
    render partial: 'stores/table', locals: { stores: stores }
  end

  it 'has table with name and address columns' do
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Address')
  end

  it 'displays the name, address, phone, and sales_email of that store' do
    expect(rendered).to have_selector('td', text: stores.first.name)
    stores.first.address_array.each do |addr_field|
      expect(rendered).to have_text addr_field
    end
    expect(rendered).to have_text stores.first.phone
    expect(rendered).to have_text stores.first.sales_email
  end

  it 'actions column has a link to edit and a link to destroy' do
    expect(rendered).to have_selector("tr#store_#{stores.first.id} td a[href='#{store_path(stores.first)}']")
    expect(rendered).to have_selector("tr#store_#{stores.first.id} td a[href='#{edit_store_path(stores.first)}']")
  end
end

require 'spec_helper'

describe 'stores/_table.html.erb', store_spec: true do
  let!(:stores) { [build_stubbed(:valid_store)] }

  before(:each) do
    assign(:stores, stores)
    render partial: 'stores/table', locals: { stores: stores }
  end

  it 'has table with name and sku columns' do
    expect(rendered).to have_selector('th', text: 'Name')
  end

  it 'displays the name and sku of that store' do
    expect(rendered).to have_selector('td', text: stores.first.name)
  end

  it 'actions column has a link to edit and a link to destroy' do
    expect(rendered).to have_selector("tr#store_#{stores.first.id} td a[href='#{store_path(stores.first)}']")
    expect(rendered).to have_selector("tr#store_#{stores.first.id} td a[href='#{edit_store_path(stores.first)}']")
  end
end
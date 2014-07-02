require 'spec_helper'

describe 'stores/_table.html.erb', store_spec: true do

  let!(:stores) do
    [create(:valid_store)]
    assign(:stores, Store.all)
  end

  it 'has table with name and sku columns' do
    render partial: 'stores/table', locals: {stores: stores}
    expect(rendered).to have_selector('th', text: 'Name')
  end

  it 'displays the name and sku of that store' do
    render partial: 'stores/table', locals: {stores: stores}
    expect(rendered).to have_selector('td', text: stores.first.name)
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'stores/table', locals: {stores: stores}
    expect(rendered).to have_selector("tr#store_#{stores.first.id} td a[href='#{store_path(stores.first)}']")
    expect(rendered).to have_selector("tr#store_#{stores.first.id} td a[href='#{edit_store_path(stores.first)}']")
  end
end
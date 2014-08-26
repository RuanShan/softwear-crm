require 'spec_helper'

describe 'shipping_methods/_table.html.erb' do

  let(:shipping_methods) { [create(:valid_shipping_method)] }

  it 'has a table with the name, tracking url, and actions' do
    render partial: 'shipping_methods/table', locals: {shipping_methods: shipping_methods}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Tracking URL')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'shipping_methods/table', locals: {shipping_methods: shipping_methods}
    expect(rendered).to have_selector("tr#shipping_method_#{shipping_methods.first.id} td a[href='#{edit_shipping_method_path(shipping_methods.first)}']")
    expect(rendered).to have_selector("tr#shipping_method_#{shipping_methods.first.id} td a[href='#{shipping_method_path(shipping_methods.first)}']")
  end
end
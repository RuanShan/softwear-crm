require 'spec_helper'

describe 'shipping_methods/index.html.erb' do

  it 'has a table of shipping_methods' do
    assign(:shipping_methods, ShippingMethod.all)
    render
    expect(rendered).to have_selector("table#shipping_methods_list")
  end
end
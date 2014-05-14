require 'spec_helper'

describe 'shipping_methods/new.html.erb' do
  it 'has a form to create a new shipping method' do
    assign(:shipping_method, ShippingMethod.new)
    render
    expect(rendered).to have_selector("form[action='#{shipping_methods_path}'][method='post']")
  end
end
require 'spec_helper'

describe 'shipping_methods/edit.html.erb' do
  let(:shipping_method) { create(:valid_shipping_method) }

  it 'has a form to create a new mockup group' do
    assign(:shipping_method, shipping_method)
    render file: 'shipping_methods/edit', id: shipping_method.to_param
    expect(rendered).to have_selector("form[action='#{shipping_method_path(shipping_method)}'][method='post']")
  end
end
require 'spec_helper'

describe 'shipping_methods/_form.html.erb' do
  before(:each){ render partial: 'shipping_methods/form', locals: { shipping_method: ShippingMethod.new}}

  it 'has text_field for name, tracking_url and a submit button' do
    expect(rendered).to have_selector("input#shipping_method_name")
    expect(rendered).to have_selector("input#shipping_method_tracking_url")
    expect(rendered).to have_selector("button")
  end
end
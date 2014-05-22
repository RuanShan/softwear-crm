require 'spec_helper'

describe 'brands/_form.html.erb' do
  before(:each){ render partial: 'brands/form', locals: { brand: Brand.new}}

  it 'has text_field for name, sku and a submit button' do
    expect(rendered).to have_selector("input#brand_name")
    expect(rendered).to have_selector("input#brand_sku")
    expect(rendered).to have_selector("button")
  end
end
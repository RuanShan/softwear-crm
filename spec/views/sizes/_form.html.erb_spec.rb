require 'spec_helper'

describe 'sizes/_form.html.erb' do
  before(:each){ render partial: 'sizes/form', locals: { size: Size.new}}

  it 'has text_field for name, catalog_no, description, sku and a submit button' do
    expect(rendered).to have_selector("input#size_name")
    expect(rendered).to have_selector("input#size_sku")
    expect(rendered).to have_selector("input#size_sort_order")
    expect(rendered).to have_selector("button")
  end
end
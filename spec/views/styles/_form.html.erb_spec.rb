require 'spec_helper'

describe 'styles/_form.html.erb' do
  before(:each){ render partial: 'styles/form', locals: { style: Style.new}}

  it 'has text_field for name, catalog_no, description, sku and a submit button' do
    expect(rendered).to have_selector("input#style_name")
    expect(rendered).to have_selector("input#style_catalog_no")
    expect(rendered).to have_selector("input#style_description")
    expect(rendered).to have_selector("input#style_sku")
    expect(rendered).to have_selector("button")
  end
end
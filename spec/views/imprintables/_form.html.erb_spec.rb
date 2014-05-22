require 'spec_helper'

describe 'imprintables/_form.html.erb' do
  before(:each){ render partial: 'imprintables/form', locals: { imprintable: Imprintable.new}}

  it 'has text_field for name, catalog_number, description and a submit button' do
    expect(rendered).to have_selector("input#imprintable_name")
    expect(rendered).to have_selector("input#imprintable_catalog_number")
    expect(rendered).to have_selector("input#imprintable_description")
    expect(rendered).to have_selector("button")
  end
end
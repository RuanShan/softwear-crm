require 'spec_helper'

describe 'colors/_form.html.erb' do
  before(:each){ render partial: 'colors/form', locals: { color: Color.new}}

  it 'has text_field for name, sku and a submit button' do
    expect(rendered).to have_selector("input#color_name")
    expect(rendered).to have_selector("input#color_sku")
    expect(rendered).to have_selector("button")
  end
end
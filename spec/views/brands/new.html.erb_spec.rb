require 'spec_helper'

describe 'brands/new.html.erb', brand_spec: true do
  it 'has a form to create a new brand' do
    assign(:brand, Brand.new)
    render
    expect(rendered).to have_selector("form[action='#{brands_path}'][method='post']")
  end
end
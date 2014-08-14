require 'spec_helper'

describe 'brands/new.html.erb', brand_spec: true do
  before(:each) do
    assign(:brand, Brand.new)
    render
  end

  it 'has a form to create a new brand' do
    expect(rendered).to have_selector("form#new_brand[action='#{brands_path}']")
  end
end

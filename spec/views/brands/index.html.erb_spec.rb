require 'spec_helper'

describe 'brands/index.html.erb', brand_spec: true do

  it 'has a table of brands' do
    assign(:brands, Brand.all)
    render
    expect(rendered).to have_selector("table#brands_list")
  end
end
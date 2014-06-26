require 'spec_helper'

describe 'brands/index.html.erb', brand_spec: true do

  before(:each) do
    assign(:brands, Kaminari.paginate_array([]).page(1))
    render
  end

  it 'has a table of brands and paginates' do
    expect(rendered).to have_selector("table#brands_list")
    expect(rendered).to have_selector("div.pagination")
  end
end
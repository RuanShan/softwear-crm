require 'spec_helper'

describe 'brands/index.html.erb', brand_spec: true do

  before(:each) do
    assign(:brands, Kaminari.paginate_array([]).page(1))
    render
  end

  it 'has a table of brands' do
    expect(rendered).to have_selector('table#brands_list')
  end

  it 'paginates' do
    expect(rendered).to have_selector('div.pagination')
  end
end
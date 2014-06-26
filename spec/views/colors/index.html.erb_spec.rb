require 'spec_helper'

describe 'colors/index.html.erb', color_spec: true do

  before(:each) do
    assign(:colors, Kaminari.paginate_array([]).page(1))
    render
  end

  it 'has a table of brands and paginates' do
    expect(rendered).to have_selector("table#colors_list")
    expect(rendered).to have_selector("div.pagination")
  end
end
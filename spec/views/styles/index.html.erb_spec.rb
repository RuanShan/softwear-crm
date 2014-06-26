require 'spec_helper'

describe 'styles/index.html.erb', style_spec: true do
  before(:each) do
    assign(:styles, Kaminari.paginate_array(Style.all).page(1))
    render
  end

  it 'has a table of styles' do
    expect(rendered).to have_selector("table#styles_list")
  end

  it 'paginates styles' do
    expect(rendered).to have_selector("div.pagination")
  end
end

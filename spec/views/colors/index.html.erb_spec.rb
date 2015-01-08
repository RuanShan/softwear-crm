require 'spec_helper'

describe 'colors/index.html.erb', color_spec: true, story_221: true do

  before(:each) do
    assign(:colors, Kaminari.paginate_array([]).page(1))
    render
  end

  it 'has a table of colors' do
    expect(rendered).to have_selector('table#colors_list')
  end

  it 'paginates' do
    expect(rendered).to have_selector('div.pagination')
  end

  it 'renders the _search partial' do
    expect(rendered).to render_template(partial: '_search')
  end
end

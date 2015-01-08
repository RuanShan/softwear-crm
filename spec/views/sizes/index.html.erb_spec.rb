require 'spec_helper'

describe 'sizes/index.html.erb', size_spec: true, story_221: true do
  before(:each) do
    assign(:sizes, [build_stubbed(:valid_size)])
    render
  end

  it 'has a table of sizes' do
    expect(rendered).to have_selector('table#js-sizes-list')
  end

  it 'renders the _search partial' do
    expect(rendered).to render_template(partial: '_search')
  end
end

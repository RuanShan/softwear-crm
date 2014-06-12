require 'spec_helper'

describe 'sizes/index.html.erb', size_spec: true do
  it 'has a table of sizes' do
    assign(:sizes, Size.all)
    render
    expect(rendered).to have_selector("table#sizes_list")
  end
end

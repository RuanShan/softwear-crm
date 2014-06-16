require 'spec_helper'

describe 'colors/index.html.erb', color_spec: true do

  it 'has a table of colors' do
    assign(:colors, Color.all)
    render
    expect(rendered).to have_selector("table#colors_list")
  end
end
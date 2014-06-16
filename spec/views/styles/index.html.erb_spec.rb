require 'spec_helper'

describe 'styles/index.html.erb', style_spec: true do
  it 'has a table of styles' do
    assign(:styles, Style.all)
    render
    expect(rendered).to have_selector("table#styles_list")
  end
end

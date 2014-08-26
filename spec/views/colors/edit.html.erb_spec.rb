require 'spec_helper'

describe 'colors/edit.html.erb', color_spec: true do
  let(:color) { build_stubbed(:valid_color) }

  before(:each) do
    assign(:color, color)
    render file: 'colors/edit', id: color.to_param
  end

  it 'has a form to create a new mockup group' do
    expect(rendered).to have_selector("form[action='#{color_path(color)}'][method='post']")
  end
end

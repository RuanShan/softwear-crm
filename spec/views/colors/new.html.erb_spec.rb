require 'spec_helper'

describe 'colors/new.html.erb', color_spec: true do
  before(:each) do
    assign(:color, Color.new)
    render
  end

  it 'has a form to create a new color' do
    expect(rendered).to have_selector("form[action='#{colors_path}'][method='post']")
  end
end

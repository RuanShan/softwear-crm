require 'spec_helper'

describe 'colors/new.html.erb' do
  it 'has a form to create a new color' do
    assign(:color, Color.new)
    render
    expect(rendered).to have_selector("form[action='#{colors_path}'][method='post']")
  end
end
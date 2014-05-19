require 'spec_helper'

describe 'styles/new.html.erb' do
  it 'has a form to create a new style' do
    assign(:style, Style.new)
    render
    expect(rendered).to have_selector("form[action='#{styles_path}'][method='post']")
  end
end
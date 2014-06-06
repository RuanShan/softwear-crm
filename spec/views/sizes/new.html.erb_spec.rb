require 'spec_helper'

describe 'sizes/new.html.erb', size_spec: true do
  it 'has a form to create a new size' do
    assign(:size, Size.new)
    render
    expect(rendered).to have_selector("form[action='#{sizes_path}'][method='post']")
  end
end
require 'spec_helper'

describe 'sizes/new.html.erb', size_spec: true do
  before(:each) do
    assign(:size, Size.new)
    render
  end

  it 'has a form to create a new size' do
    expect(rendered).to have_selector("form[action='#{sizes_path}'][method='post']")
  end
end

require 'spec_helper'

describe 'sizes/edit.html.erb', size_spec: true do
  let!(:size) { build_stubbed(:valid_size) }

  before(:each) do
    assign(:size, size)
    render file: 'sizes/edit', id: size.to_param
  end

  it 'has a form to create a new mockup group' do
    expect(rendered).to have_selector("form[action='#{size_path(size)}'][method='post']")
  end
end

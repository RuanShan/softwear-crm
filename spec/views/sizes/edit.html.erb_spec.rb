require 'spec_helper'

describe 'sizes/edit.html.erb' do
  let(:size){ create(:valid_size) }

  it 'has a form to create a new mockup group' do
    assign(:size, size)
    render file: 'sizes/edit', id: size.to_param
    expect(rendered).to have_selector("form[action='#{size_path(size)}'][method='post']")
  end
end
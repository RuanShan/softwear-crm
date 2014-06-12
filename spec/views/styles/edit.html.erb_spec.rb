require 'spec_helper'

describe 'styles/edit.html.erb', style_spec: true do
  let(:style){ create(:valid_style) }

  it 'has a form to create a new mockup group' do
    assign(:style, style)
    render file: 'styles/edit', id: style.to_param
    expect(rendered).to have_selector("form[action='#{style_path(style)}'][method='post']")
  end
end

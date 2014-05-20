require 'spec_helper'

describe 'colors/edit.html.erb' do
  let(:color){ create(:valid_color) }

  it 'has a form to create a new mockup group' do
    assign(:color, color)
    render file: 'colors/edit', id: color.to_param
    expect(rendered).to have_selector("form[action='#{color_path(color)}'][method='post']")
  end
end
require 'spec_helper'

describe 'imprint_methods/edit.html.erb', imprint_method_spec: true do
  let(:imprint_method){ create(:valid_imprint_method_with_color_and_location) }

  it 'has a form to edit the imprint method' do
    assign(:imprint_method, imprint_method)
    render file: 'imprint_methods/edit', id: imprint_method.to_param
    expect(rendered).to have_selector("form[action='#{imprint_method_path(imprint_method)}'][method='post']")
  end
end
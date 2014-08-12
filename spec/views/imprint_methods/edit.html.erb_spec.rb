require 'spec_helper'

describe 'imprint_methods/edit.html.erb', imprint_methods_spec: true do
  let(:imprint_method){ build_stubbed(:blank_imprint_method) }

  it 'has a form to edit the imprint method' do
    assign(:imprint_method, imprint_method)
    render file: 'imprint_methods/edit', id: imprint_method.to_param
    expect(rendered).to have_selector("form[action='#{imprint_method_path(imprint_method)}'][method='post']")
  end
end
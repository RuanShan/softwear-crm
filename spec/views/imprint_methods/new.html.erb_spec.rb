require 'spec_helper'

describe 'imprint_methods/new.html.erb', imprint_methods_spec: true do
  it 'has a form to create a new imprint method' do
    assign(:imprint_method, ImprintMethod.new)
    render
    expect(rendered).to have_selector("form[action='#{imprint_methods_path}'][method='post']")
  end
end
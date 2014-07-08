require 'spec_helper'

describe 'imprint_methods/index.html.erb', imprint_method_spec: true do

  it 'has a table of imprint_methods' do
    assign(:imprint_methods, ImprintMethod.all)
    render
    expect(rendered).to have_selector("table#imprint_methods_list")
  end
end
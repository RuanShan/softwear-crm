require 'spec_helper'

describe 'imprint_methods/_form.html.erb', imprint_method_spec: true do
  before(:each) { render partial: 'imprint_methods/form', locals: { imprint_method: ImprintMethod.new}}

  it 'has text_field for name and a submit button' do
    expect(rendered).to have_selector('input#imprint_method_name')
    expect(rendered).to have_selector('select#imprint_method_ink_color_names')
    expect(rendered).to have_selector('a.add_nested_fields', text: 'Add Print Location')
    expect(rendered).to have_selector('a.add_nested_fields', text: 'Add Option Type')
  end
end

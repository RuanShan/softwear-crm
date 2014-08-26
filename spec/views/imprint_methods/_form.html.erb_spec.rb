require 'spec_helper'

describe 'imprint_methods/_form.html.erb', imprint_method_spec: true do
  before(:each) { render partial: 'imprint_methods/form', locals: { imprint_method: ImprintMethod.new}}

  it 'has text_field for name and a submit button' do
    expect(rendered).to have_selector('input#imprint_method_name')
    expect(rendered).to have_selector('a.js-add-fields', text: 'Add Ink color')
    expect(rendered).to have_selector('a.js-add-fields', text: 'Add Print Location')
  end
end
require 'spec_helper'

describe 'imprint_methods/_form.html.erb' do
  before(:each){ render partial: 'imprint_methods/form', locals: { imprint_method: ImprintMethod.new}}

  it 'has text_field for name, production_name, and a submit button' do
    expect(rendered).to have_selector("input#imprint_method_name")
    expect(rendered).to have_selector("input#imprint_method_production_name")
    expect(rendered).to have_selector("button")
  end
end
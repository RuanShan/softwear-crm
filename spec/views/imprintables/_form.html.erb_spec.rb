require 'spec_helper'

describe 'imprintables/_form.html.erb' do
  before(:each){ render partial: 'imprintables/form', locals: { imprintable: Imprintable.new}}

  it 'has text_field for name, catalog_number, description and a submit button' do
    imprintable = Imprintable.new
    f = LancengFormBuilder.dummy_for imprintable
    render partial: 'imprintables/form', locals: {imprintable: imprintable, f: f}
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :catalog_number
      expect(rendered).to have_field_for :description
      expect(rendered).to have_selector('button')
    end
  end
end
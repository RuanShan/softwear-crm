require 'spec_helper'

describe 'imprintables/_form.html.erb', imprintable_spec: true do
  before(:each){ render partial: 'imprintables/form', locals: { imprintable: Imprintable.new}}

  it 'has text_field for name, catalog_number, description and a submit button' do
    imprintable = Imprintable.new
    f = LancengFormBuilder.dummy_for imprintable
    render partial: 'imprintables/form', locals: {imprintable: imprintable, f: f}
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :special_considerations
      expect(rendered).to have_field_for :flashable
      expect(rendered).to have_field_for :polyester
      expect(rendered).to have_selector('button')
    end
  end
end
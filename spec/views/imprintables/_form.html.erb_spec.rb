require 'spec_helper'

describe 'imprintables/_form.html.erb', imprintable_spec: true do
  before(:each){ render partial: 'imprintables/form', locals: { imprintable: Imprintable.new } }

  it 'has text_field for special_considerations, material, proofing template name, standard offering, flashable, polyester, sizing category, brand id, stye id, and a submit button' do
    imprintable = Imprintable.new
    f = LancengFormBuilder.dummy_for imprintable
    render partial: 'imprintables/form', locals: {imprintable: imprintable, f: f}
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :special_considerations
      expect(rendered).to have_field_for :material
      expect(rendered).to have_field_for :proofing_template_name
      expect(rendered).to have_field_for :standard_offering
      expect(rendered).to have_field_for :flashable
      expect(rendered).to have_field_for :polyester
      expect(rendered).to have_field_for :sizing_category
      expect(rendered).to have_field_for :style_id
      expect(rendered).to have_selector('button')
    end
  end
end

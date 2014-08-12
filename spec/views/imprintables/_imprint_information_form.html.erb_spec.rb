require 'spec_helper'

describe 'imprintables/_imprint_information_form', imprintable_spec: true do

  it 'has field for sizing category, polyester, flashable, proofing template name, special considerations, compatible imprint methods and imprint category' do
    imprintable = Imprintable.new
    f = LancengFormBuilder.dummy_for imprintable
    assign(:model_collection_hash, { sizing_categories_collection: [], imprint_method_collection: [] })
    render partial: 'imprintables/imprint_information_form', locals: { imprintable: imprintable, f: f }
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :sizing_category
      expect(rendered).to have_field_for :polyester
      expect(rendered).to have_field_for :flashable
      expect(rendered).to have_field_for :proofing_template_name
      expect(rendered).to have_field_for :special_considerations
      expect(rendered).to have_field_for :compatible_imprint_method_ids
      expect(rendered).to have_content 'Add Imprintable Category'
    end
  end
end
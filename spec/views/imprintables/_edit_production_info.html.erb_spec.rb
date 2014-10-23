require 'spec_helper'

describe 'imprintables/_edit_production_info.html.erb', imprintable_spec: true do

  before(:each) do
    imprintable = build_stubbed(:valid_imprintable)
    f = test_form_for imprintable, builder: LancengFormBuilder
    mch = {
            imprint_method_collection: []
          }
    render partial: 'imprintables/edit_production_info',
           locals: {
                     imprintable: imprintable,
                     f: f,
                     model_collection_hash: mch
                   }
  end

  it 'has field for brand, style name, catalog no, description' do
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :polyester
      expect(rendered).to have_field_for :material
      expect(rendered).to have_field_for :weight
      expect(rendered).to have_field_for :max_imprint_width
      expect(rendered).to have_field_for :max_imprint_height
      expect(rendered).to have_field_for :sizing_category
      expect(rendered).to have_field_for :flashable
      expect(rendered).to have_field_for :proofing_template_name
      expect(rendered).to have_field_for :special_considerations
      expect(rendered).to have_field_for :compatible_imprint_method_ids
    end
  end
end

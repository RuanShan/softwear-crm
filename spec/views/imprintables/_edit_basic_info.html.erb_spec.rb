require 'spec_helper'

describe 'imprintables/_edit_basic_info.html.erb', imprintable_spec: true do

  before(:each) do
    imprintable = build_stubbed(:valid_imprintable)
    f = test_form_for imprintable, builder: LancengFormBuilder
    mch = {
            brand_collection: [],
            store_collection: [],
            imprintable_collection: [],
          }
    render partial: 'imprintables/edit_basic_info',
           locals: {
                     imprintable: imprintable,
                     f: f,
                     model_collection_hash: mch
                   }
  end

  it 'has field for brand, style name, catalog no, description' do
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :brand_id
      expect(rendered).to have_field_for :style_name
      expect(rendered).to have_field_for :style_catalog_no
      expect(rendered).to have_field_for :style_description
    end
  end
end

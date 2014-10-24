require 'spec_helper'

describe 'imprintables/_edit_retail_info.html.erb', imprintable_spec: true do

  before(:each) do
    imprintable = build_stubbed(:valid_imprintable)
    f = test_form_for imprintable, builder: LancengFormBuilder
    mch = {
            brand_collection: [],
            store_collection: [],
            imprintable_collection: [],
          }
    render partial: 'imprintables/edit_retail_info',
           locals: {
                     imprintable: imprintable,
                     f: f,
                     model_collection_hash: mch
                   }
  end

  it 'has field for brand, style name, catalog no, description' do
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_field_for :common_name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :base_upcharge
      expect(rendered).to have_field_for :xxl_upcharge
      expect(rendered).to have_field_for :xxxl_upcharge
      expect(rendered).to have_field_for :xxxxl_upcharge
      expect(rendered).to have_field_for :xxxxxl_upcharge
      expect(rendered).to have_field_for :xxxxxxl_upcharge
    end
  end
end

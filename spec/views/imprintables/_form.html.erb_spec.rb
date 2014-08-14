require 'spec_helper'

describe 'imprintables/_form.html.erb', imprintable_spec: true do

  before(:each) do
    imprintable = build_stubbed(:valid_imprintable)
    f = test_form_for imprintable, builder: LancengFormBuilder
    assign(:model_collection_hash,
           {
             brand_collection: [],
             store_collection: [],
             imprintable_collection: [],
             imprint_method_collection: [],
             all_colors: [],
             all_sizes: []
           }
    )
    render partial: 'imprintables/form',
           locals: { imprintable: imprintable, f: f }
  end

  it 'has text_field for special_considerations, material,
        proofing template name, standard offering, flashable, polyester,
        sizing category, brand, style name, style catalog no, style description,
        style sku, retail, and a submit button' do
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :special_considerations
      expect(rendered).to have_field_for :material
      expect(rendered).to have_field_for :weight
      expect(rendered).to have_field_for :max_imprint_width
      expect(rendered).to have_field_for :max_imprint_height
      expect(rendered).to have_field_for :proofing_template_name
      expect(rendered).to have_field_for :standard_offering
      expect(rendered).to have_field_for :flashable
      expect(rendered).to have_field_for :polyester
      expect(rendered).to have_field_for :sizing_category
      expect(rendered).to have_field_for :tag_list
      expect(rendered).to have_field_for :sample_location_ids
      expect(rendered).to have_field_for :coordinate_ids
      expect(rendered).to have_field_for :compatible_imprint_method_ids
      expect(rendered).to have_field_for :main_supplier
      expect(rendered).to have_field_for :supplier_link
      expect(rendered).to have_field_for :base_price
      expect(rendered).to have_field_for :xxl_price
      expect(rendered).to have_field_for :xxxl_price
      expect(rendered).to have_field_for :xxxxl_price
      expect(rendered).to have_field_for :xxxxxl_price
      expect(rendered).to have_field_for :xxxxxxl_price
      expect(rendered).to have_field_for :style_name
      expect(rendered).to have_field_for :style_catalog_no
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :style_description
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_field_for :brand_id
      expect(rendered).to have_selector('button')
    end
  end
end

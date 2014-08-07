require 'spec_helper'

describe 'imprintables/_basic_information_form.html.erb', imprintable_spec: true do

  it 'has field for brand, style name, style catalog no, sku, retail, style description, standard offering, material, weight, max imprint width, max imprint height, tag list, sample locations and coordinates' do
    imprintable = Imprintable.new
    f = LancengFormBuilder.dummy_for imprintable
    assign(:model_collection_hash, { brand_collection: [], store_collection: [], imprintable_collection: [], size_collection: [], color_collection: [] })
    render partial: 'imprintables/basic_information_form', locals: { imprintable: imprintable, f: f }
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :brand_id
      expect(rendered).to have_field_for :style_name
      expect(rendered).to have_field_for :style_catalog_no
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_field_for :style_description
      expect(rendered).to have_field_for :standard_offering
      expect(rendered).to have_field_for :material
      expect(rendered).to have_field_for :weight
      expect(rendered).to have_field_for :max_imprint_width
      expect(rendered).to have_field_for :max_imprint_height
      expect(rendered).to have_field_for :tag_list
      expect(rendered).to have_field_for :sample_location_ids
      expect(rendered).to have_field_for :coordinate_ids
    end
  end
end

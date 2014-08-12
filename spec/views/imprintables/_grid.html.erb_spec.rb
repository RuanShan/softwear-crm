require 'spec_helper'

describe 'imprintables/_grid.html.erb', imprintable_variant_spec: true do
  context 'there are no variants' do
    it 'has table containing dropdown menus to select size and colors' do
      imprintable = Imprintable.new

      f = LancengFormBuilder.dummy_for imprintable
      assign(:model_collection_hash, { color_collection: [], size_collection: [] } )
      render partial: 'grid', locals: { imprintable: imprintable, f: f, size_variants: [],
                                        color_variants: [], variants_array: [] }
      within_form_for ImprintableVariant, noscope: true do
        expect(rendered).to have_css('#imprintable_variants_list')
        expect(rendered).to have_css('#size_button')
        expect(rendered).to have_css('#color_button')
      end
    end
  end

  context 'there is a variant' do
    it 'has a table containing size columns and color rows' do
      imprintable_variant = FactoryGirl.create(:valid_imprintable_variant)
      f = LancengFormBuilder.dummy_for :imprintable
      assign(:model_collection_hash, { color_collection: [], size_collection: [] } )
      render partial: 'grid', locals: { imprintable: imprintable_variant.imprintable, imprintable_variant: imprintable_variant, f: f,
                                        size_variants: [imprintable_variant], color_variants: [imprintable_variant],
                                        variants_array: [imprintable_variant] }
      within_form_for ImprintableVariant, noscope: true do
        expect(rendered).to have_css('#row_1')
        expect(rendered).to have_css('#col_1')
      end
    end
  end
end

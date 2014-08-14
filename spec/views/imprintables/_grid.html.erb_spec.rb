require 'spec_helper'

describe 'imprintables/_grid.html.erb', imprintable_variant_spec: true do
  context 'there are no variants' do
    before(:each) do
      imprintable = build_stubbed(:valid_imprintable)

      f = LancengFormBuilder.dummy_for imprintable
      assign(:model_collection_hash, { color_collection: [], size_collection: [] } )
      render partial: 'grid',
             locals: {
               imprintable: imprintable,
               f: f,
               size_variants: [],
               color_variants: [],
               variants_array: []
             }
    end

    it 'has table containing dropdown menus to select size and colors' do
      within_form_for ImprintableVariant, noscope: true do
        expect(rendered).to have_css('#imprintable_variants_list')
        expect(rendered).to have_css('#size_button')
        expect(rendered).to have_css('#color_button')
      end
    end
  end

  context 'there is a variant' do
    before(:each) do
      imprintable_variant = build_stubbed(:valid_imprintable_variant)
      allow(imprintable_variant).to receive(:size).and_return(build_stubbed(:valid_size))
      allow(imprintable_variant).to receive(:color).and_return(build_stubbed(:valid_color))
      f = LancengFormBuilder.dummy_for :imprintable
      assign(:model_collection_hash, { color_collection: [], size_collection: [] } )
      render partial: 'grid',
             locals: {
               imprintable: imprintable_variant.imprintable,
               imprintable_variant: imprintable_variant,
               f: f,
               size_variants: [imprintable_variant],
               color_variants: [imprintable_variant],
               variants_array: [imprintable_variant]
             }
    end

    it 'has a table containing size columns and color rows' do
      within_form_for ImprintableVariant, noscope: true do
        expect(rendered).to have_css('#row_1')
        expect(rendered).to have_css('#col_1')
      end
    end
  end
end

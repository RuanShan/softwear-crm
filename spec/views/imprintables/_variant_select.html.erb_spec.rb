require 'spec_helper'

describe 'imprintables/_variant_select.html.erb', imprintable_variant_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }
  let(:color) { build_stubbed(:valid_color) }
  let(:size) { build_stubbed(:valid_size) }

  before(:each) do
    f = test_form_for imprintable, builder: LancengFormBuilder
    assign(:model_collection_hash, { all_colors: [color], all_sizes: [size] })
    render partial: 'variant_select',
           locals: { imprintable: imprintable, size: size, color: color, f: f }
  end

  it 'has modal select for color and size' do
    within_form_for ImprintableVariant, noscope: true do
      expect(rendered).to have_css("input[name='color[ids][]']")
      expect(rendered).to have_css('option', text: color.name)
      expect(rendered).to have_css("input[name='size[ids][]']")
      expect(rendered).to have_css('option', text: size.name)
    end
  end
end

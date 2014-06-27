require 'spec_helper'

describe 'imprintables/_variant_select.html.erb', imprintable_variant_spec: true do

  let(:imprintable) { create(:valid_imprintable) }
  let(:color) { create(:valid_color) }
  let(:size) { create(:valid_size) }

  it 'has modal select for color and size' do
    f = LancengFormBuilder.dummy_for imprintable
    render partial: 'variant_select', locals: {imprintable: imprintable, size: size, color: color, f: f}
    within_form_for ImprintableVariant, noscope: true do
      expect(rendered).to have_css("input[name='color[ids][]']")
      expect(rendered).to have_css("option", text: color.name)
      expect(rendered).to have_css("input[name='size[ids][]']")
      expect(rendered).to have_css("option", text: size.name)
    end
  end
end

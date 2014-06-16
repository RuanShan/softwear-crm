require 'spec_helper'

describe 'imprintables/_variant_select.html.erb', imprintable_variant_spec: true do
  it 'has checkboxes to select a color and a size' do
    imprintable = FactoryGirl.create(:valid_imprintable)
    size = FactoryGirl.create(:valid_size)
    color = FactoryGirl.create(:valid_color)

    f = LancengFormBuilder.dummy_for imprintable
    render partial: 'variant_select', locals: {imprintable: imprintable, size: size, color: color, f: f}
    within_form_for ImprintableVariant, noscope: true do
      expect(rendered).to have_css("#color_ids_[value='#{color.id}']")
      expect(rendered).to have_css("#size_ids_[value='#{size.id}']")
    end
  end
end

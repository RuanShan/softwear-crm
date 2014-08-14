require 'spec_helper'

describe 'imprintables/_supplier_information_form', imprintable_spec: true do
  before(:each) do
    imprintable = build_stubbed(:valid_imprintable)
    f = test_form_for imprintable, builder: LancengFormBuilder
    render partial: 'imprintables/supplier_information_form',
           locals: { imprintable: imprintable, f: f }
  end

  it 'has field for main supplier, supplier link, base price,
      xxl price, xxxl price, xxxxl price, xxxxxl price, xxxxxxl price' do
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :main_supplier
      expect(rendered).to have_field_for :supplier_link
      expect(rendered).to have_field_for :base_price
      expect(rendered).to have_field_for :xxl_price
      expect(rendered).to have_field_for :xxxl_price
      expect(rendered).to have_field_for :xxxxl_price
      expect(rendered).to have_field_for :xxxxxl_price
      expect(rendered).to have_field_for :xxxxxxl_price
    end
  end
end

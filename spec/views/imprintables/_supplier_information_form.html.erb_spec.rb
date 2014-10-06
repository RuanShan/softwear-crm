require 'spec_helper'

describe 'imprintables/_supplier_information_form', story_185: true, imprintable_spec: true do
  let(:non_retail_imprintable) { build_stubbed(:valid_imprintable, retail: false) }
  let(:retail_imprintable) { build_stubbed(:valid_imprintable, retail: true) }

  context 'when the imprintable isn\'t retail' do
    before(:each) do
      f = test_form_for non_retail_imprintable, builder: LancengFormBuilder
      render 'supplier_information_form', imprintable: non_retail_imprintable, f: f
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

    it 'doesn\'t have upcharge fields' do
      expect(rendered).to_not have_css('input#xxl_upcharge')
      expect(rendered).to_not have_css('input#xxxl_upcharge')
      expect(rendered).to_not have_css('input#xxxxl_upcharge')
      expect(rendered).to_not have_css('input#xxxxxl_upcharge')
      expect(rendered).to_not have_css('input#xxxxxxl_upcharge')
    end
  end

  context 'when the imprintable is retail' do
    before(:each) do
      f = test_form_for retail_imprintable, builder: LancengFormBuilder
      render 'supplier_information_form', imprintable: retail_imprintable, f: f
    end

    it 'has upcharge fields' do
      expect(rendered).to have_css('input#xxl_upcharge')
      expect(rendered).to have_css('input#xxxl_upcharge')
      expect(rendered).to have_css('input#xxxxl_upcharge')
      expect(rendered).to have_css('input#xxxxxl_upcharge')
      expect(rendered).to have_css('input#xxxxxxl_upcharge')
    end
  end
end

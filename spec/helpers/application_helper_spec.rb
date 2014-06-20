require 'spec_helper'

describe ApplicationHelper, application_helper_spec: true do
  describe "#model_table_row_id" do
    let! (:shipping_method) { create(:valid_shipping_method) }

    it 'returns the model name underscored and with the record id at the end' do
      expect(model_table_row_id(shipping_method)).to eq("shipping_method_#{shipping_method.id}")
    end

  end

  describe "#create_or_edit_text" do

    context 'object is a new record' do
      it 'returns Create' do
        expect(create_or_edit_text(ShippingMethod.new)).to eq('Create')
      end
    end

    context 'object is an existing record' do
      let! (:shipping_method) { create(:valid_shipping_method) }

      it 'returns Update' do
        expect(create_or_edit_text(shipping_method)).to eq('Update')
      end
    end
  end

  describe '#human_boolean' do
    it 'returns Yes when given a true value' do
      expect(human_boolean(true)).to eq('Yes')
    end
    it 'returns No when given a false value' do
      expect(human_boolean(false)).to eq('No')
    end
  end

  describe '#imprintable_modal_link' do
    let(:helpers) { ApplicationController.helpers }
    it 'renders the imprintable_modal partial with nil text, when text is not supplied' do
      imprintable = mock_model(Imprintable, id: 1)
      expect(Imprintable).to receive(:find).and_return imprintable
      expect(imprintable).to receive(:create_variants_hash).and_return( { size_variants: [], color_variants: [], variants_array: [] } )
      expect(helpers).to receive(:render).with(partial: 'imprintable_modal', locals: { modal: true, imprintable: imprintable, text: nil } )
      helpers.imprintable_modal_link(imprintable)
    end

    it 'renders the imprintable_modal partial with text when text is supplied' do
      imprintable = mock_model(Imprintable, id: 2)
      expect(Imprintable).to receive(:find).and_return imprintable
      expect(imprintable).to receive(:create_variants_hash).and_return( { size_variants: [], color_variants: [], variants_array: [] } )
      expect(helpers).to receive(:render).with(partial: 'imprintable_modal', locals: { modal: true, imprintable: imprintable, text: 'American Apparel 2001' } )
      helpers.imprintable_modal_link(imprintable, 'American Apparel 2001')
    end
  end

  describe '#nav_helper' do

  end
end

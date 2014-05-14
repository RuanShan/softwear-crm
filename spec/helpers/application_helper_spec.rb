require 'spec_helper'

describe ApplicationHelper do
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
end

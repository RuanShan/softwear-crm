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

  describe '#time_format' do
    context 'datetime is nil' do
      it 'should return nil' do
        expect(time_format('')).to eq(nil)
      end
    end

    context 'there is a valid datetime' do
      let!(:datetime) { DateTime.new(1991, 9, 25) }
      it 'should return a formatted date' do
        expect(time_format(datetime)).to eq('09/25/1991 12:00 AM')
      end
    end

  end
end

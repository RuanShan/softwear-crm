require 'spec_helper'

describe ApplicationHelper do
  describe "#model_table_row_id" do
    let! (:shipping_method) { create(:valid_shipping_method) }

    it 'returns the model name underscored and with the record id at the end' do
      expect(model_table_row_id(shipping_method)).to eq("shipping_method_#{shipping_method.id}")
    end

  end
end

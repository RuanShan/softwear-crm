require 'spec_helper'

describe LineItem, line_item_spec: true do
  context 'when validating' do
    it { should validate_presence_of :name }
  end

  it 'price method returns quantity times unit price' do
    line_item = create :line_item
    expect(line_item.price).to eq line_item.unit_price * line_item.quantity
  end
end
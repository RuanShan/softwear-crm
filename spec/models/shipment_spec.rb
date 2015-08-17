require 'spec_helper'

describe Shipment do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :status }
  end

  describe '#status' do
    context 'on creation' do
      it 'is set to "pending"', story_860: true do
        expect(create(:shipment).status).to eq 'pending'
      end

      context 'when a tracking number is provided', story_860: true do
        it 'is set to "shipped"' do
          expect(create(:shipment, tracking_number: '123').status).to eq 'shipped'
        end
      end
    end
  end
end

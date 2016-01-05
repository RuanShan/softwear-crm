require 'spec_helper'

describe Shipment do
  describe 'Validations' do
    it {is_expected.to validate_presence_of :name }
    it {is_expected.to validate_presence_of :city }
    it {is_expected.to validate_presence_of :state }
    it {is_expected.to validate_presence_of :address_1 }
    it {is_expected.to validate_presence_of :zipcode }
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

  describe 'when status gets changed to shipped', story_1076: true do
    subject { create(:shipment) }

    it 'has its order update notification state' do
      expect(subject.shippable.notification_state).to_not eq 'shipped'
      subject.tracking_number = 'tracking'
      subject.save!
      expect(subject.shippable.reload.notification_state).to eq 'shipped'
    end
  end
end

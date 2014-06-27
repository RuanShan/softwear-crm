require 'spec_helper'

describe Payment, payment_spec: true do
  describe 'Relationship' do
    it { should belong_to(:order) }
    it { should belong_to(:store) }
    it { should belong_to(:user).with_foreign_key(:salesperson_id) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:store) }
  end

  describe '#is_refunded?' do
    context 'the payment has been refunded' do
      let!(:refunded_payment) { create(:refunded_payment) }
      it 'returns true' do
        expect(refunded_payment.is_refunded?).to be_truthy
        expect(refunded_payment.refund_reason).to_not be_nil
      end
    end

    context 'the payment has not been refunded' do
      let!(:payment) { create(:valid_payment) }
      it 'returns false' do
        expect(payment.is_refunded?).to be_falsey
        expect(payment.refund_reason).to be_nil
      end
    end
  end
end

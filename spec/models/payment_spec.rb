require 'spec_helper'

describe Payment, payment_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationship' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to belong_to(:salesperson).class_name('User') }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:store) }
  end

  describe '#is_refunded?' do
    context 'the payment has been refunded' do
      let(:refunded_payment) { build_stubbed(:blank_payment, refunded: true, refund_reason: 'reason') }
      it 'returns true' do
        expect(refunded_payment.is_refunded?).to be_truthy
        expect(refunded_payment.refund_reason).to_not be_nil
      end
    end

    context 'the payment has not been refunded' do
      let(:payment) { build_stubbed(:blank_payment) }
      it 'returns false' do
        expect(payment.is_refunded?).to be_falsey
        expect(payment.refund_reason).to be_nil
      end
    end
  end
end

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
    it { is_expected.to validate_presence_of(:payment_method) }
    it { is_expected.to validate_presence_of(:salesperson) }
    it { is_expected.to validate_presence_of(:amount) }

    context 'when payment_method = 2' do
      before { subject.payment_method = 2 }

      it { is_expected.to validate_presence_of :cc_name }
      it { is_expected.to validate_presence_of :cc_number }
    end

    context 'when payment_method = 5' do
      before { subject.payment_method = 5 }

      it { is_expected.to validate_presence_of :t_name }
      it { is_expected.to validate_presence_of :t_company_name }
      it { is_expected.to validate_presence_of :tf_number }
    end

    context 'when payment_method = 4' do
      before { subject.payment_method = 4 }

      it { is_expected.to validate_presence_of :pp_transaction_id }
    end

    context 'when payment_method = 6' do
      before { subject.payment_method = 6 }

      it { is_expected.to validate_presence_of :t_name }
      it { is_expected.to validate_presence_of :t_company_name }
      it { is_expected.to validate_presence_of :t_description }
    end

    context 'when the amount overflows the order balance', amount_overflow: true do
      let!(:order) { create(:order_with_job) }
      subject { build(:credit_card_payment, order_id: order.id, amount: 5.00) }

      before do
        allow_any_instance_of(Order).to receive(:balance_excluding).with(subject).and_return 3.50
      end

      it 'is invalid' do
        expect(subject).to_not be_valid
        expect(subject.errors[:amount].first).to include "overflows the order's balance by $1.50"
        expect(subject.errors[:amount].first).to include "set to $3.50 to complete payment"
      end
    end
  end

  describe '#cc_number=', cc_number: true do
    subject { build(:credit_card_payment) }

    it 'turns all but the last 4 digits into "x"' do
      subject.cc_number = '1234 5678 4321 1122'
      expect(subject.cc_number).to eq 'xxxx xxxx xxxx 1122'

      subject.cc_number = '123456784211122'
      expect(subject.cc_number).to eq 'xxxxxxxxxxx1122'
    end

    it 'stores the whole thing in an instance variable (not saved to db)' do
      subject.cc_number = '1234 5678 4321 1122'
      expect(subject.instance_variable_get(:@actual_cc_number)).to eq '1234 5678 4321 1122'
    end
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

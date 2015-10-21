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

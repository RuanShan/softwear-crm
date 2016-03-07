require 'spec_helper'

describe Payment, payment_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationship' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:store) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:store) }
    it { is_expected.to validate_presence_of(:payment_method) }
    it { is_expected.to validate_presence_of(:amount) }

    context 'when payment_method = 8' do
      before { subject.payment_method = 8 }

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

  describe '#is_refunded?', refunding: true do
    context 'the payment has a refund discount' do
      before do
        allow_any_instance_of(Order).to receive(:balance_excluding).and_return 1000
      end

      let(:refunded_payment) { create(:credit_card_payment, amount: 5.00) }
      let!(:discount) { create(:refund, discountable: refunded_payment, amount: 1.00) }

      it 'returns true' do
        expect(refunded_payment.reload.is_refunded?).to be_truthy
      end
    end

    context 'the payment has not been refunded' do
      let(:payment) { create(:credit_card_payment) }

      it 'returns false' do
        expect(payment.is_refunded?).to be_falsey
      end
    end
  end

  describe 'creating a credit card payment', creation: true, actual_payment: true do
    subject { build(:valid_payment, amount: 10.00, payment_method: 8, cc_name: 'Test Guy') }
    let(:mock_gateway) { double('ActiveMerchant::Gateway') }
    let(:mock_card) { double('ActiveMerchant::Billing::CreditCard', validate: {}) }

    before do
      allow_any_instance_of(Order).to receive(:balance_excluding).and_return 1000
      allow_any_instance_of(Payment).to receive(:gateway) { mock_gateway }
      allow(Setting).to receive(:payflow_login).and_return 'TestLogin'
      allow(Setting).to receive(:payflow_password).and_return 'pflowpas4wrod91jd'
    end

    context 'given all valid credit card info' do
      before do
        subject.cc_number     = '4111 1111 1111 1111'
        subject.cc_type       = 'visa'
        subject.cc_expiration = '12/22'
        subject.cc_cvc        = '123'
        expect(ActiveMerchant::Billing::CreditCard).to receive(:new).and_return mock_card
      end

      it 'is created, a purchase is made, and the PNRef is stored' do
        expect(mock_gateway).to receive(:purchase)
          .with(1000, mock_card, hash_including(order_id: subject.id))
          .and_return double('Purchase result', success?: true, params: { 'pn_ref' => 'abc123' })


        subject.save
        expect(subject.errors.full_messages).to be_empty

        expect(subject.cc_transaction).to eq 'abc123'
      end

      context 'but activemerchant fails to make the purchase' do
        it 'raises a PaymentError' do
          expect(mock_gateway).to receive(:purchase)
            .and_return double('Purchase result', success?: false, message: 'poopoo problem')

          expect{ subject.save }.to raise_error Payment::PaymentError
        end
      end
    end

    context 'given a bad card number' do
      it 'adds an error to the card number field' do
        subject.cc_number     = '123 lol'
        subject.cc_type       = 'visa'
        subject.cc_expiration = '12/22'
        subject.cc_cvc        = '123'

        expect(subject).to_not be_valid

        expect(subject.errors[:cc_number]).to_not be_empty
      end
    end

    context 'given a bad expiration' do
      it 'adds an error to the cc_expiration field' do
        subject.cc_number     = '4111 1111 1111 1111'
        subject.cc_type       = 'visa'
        subject.cc_expiration = 1.year.ago.strftime("%y/%m")
        subject.cc_cvc        = '123'

        expect(subject).to_not be_valid

        expect(subject.errors[:cc_expiration]).to_not be_empty
      end
    end
  end

  describe 'refunding a credit card payment', refunding: true, actual_payment: true do
    let(:mock_gateway) { double('ActiveMerchant::Gateway') }

    before do
      allow_any_instance_of(Order).to receive(:balance_excluding).and_return 1000
      allow_any_instance_of(Payment).to receive(:gateway) { mock_gateway }
      allow(Setting).to receive(:payflow_login).and_return 'TestLogin'
      allow(Setting).to receive(:payflow_password).and_return 'pflowpas4wrod91jd'
    end

    context 'when the refund amount is the same as the payment amount' do
      subject { create(:credit_card_payment, amount: 10.00, cc_transaction: 'abc123') }
      let(:refund) { create(:refund, discountable: subject, amount: 10.00, transaction_id: 'abc123') }

      it 'is valid and gets refunded' do
        expect(mock_gateway).to receive(:refund)
          .with(1000, 'abc123', anything)
          .and_return double('Gateway response', success?: true)

        expect(subject.errors.full_messages).to be_empty
        refund

        expect(subject.reload.totally_refunded?).to eq true
      end
    end

    context 'when the refund does not have transaction_id set' do
      subject { create(:credit_card_payment, amount: 10.00, cc_transaction: 'abc123') }
      let(:refund) { create(:refund, discountable: subject, amount: 10.00, transaction_id: nil) }

      specify 'the refund does not happen' do
        expect(mock_gateway).to_not receive(:refund)

        expect(subject.errors.full_messages).to be_empty
        refund

        expect(subject.reload.totally_refunded?).to eq true
      end
    end
  end

  describe '#sales_tax_amount', sales_tax: true do
    let(:taxable_1) { create(:taxable_non_imprintable_line_item, unit_price: 50, quantity: 1) }
    let(:taxable_2) { create(:taxable_non_imprintable_line_item, unit_price: 50, quantity: 1) }
    let(:job) { order.jobs.first }
    let!(:order) { create(:order) }

    before(:each) do
      order.jobs << create(:job)
      expect(order.jobs.size).to eq 1
      order.jobs.first.line_items << taxable_1
      order.jobs.first.line_items << taxable_2
      order.recalculate_all!
      order.reload

      expect(order.line_items.size).to eq 2
      expect(order.total).to eq 106.00
      expect(order.balance).to eq 106.00
    end

    context 'when a payment is made' do
      it 'is equal to the portion of the payment that is allocated to sales tax' do
        payment = create(:valid_payment, amount: 53.00, payment_method: 1, cc_name: 'Test Guy', order: order)
        expect(order.reload.payments.size).to eq 1
        expect(order.balance).to eq 53.00
        expect(payment.sales_tax_amount).to eq 3.00
        expect(payment.reload.sales_tax_amount).to eq 3.00
        expect(order.sales_tax_balance).to eq 3.00
      end

      it 'caps out at order#sales_tax_balance' do
        payment_1 = create(:valid_payment, amount: 53.00, payment_method: 1, cc_name: 'Test Guy', order: order)
        expect(payment_1.sales_tax_amount).to eq 3.00

        taxable_2.taxable = false
        taxable_2.save!
        order.recalculate_taxable_total!

        expect(order.reload.balance).to eq 50.00

        payment_2 = create(:valid_payment, amount: 5.00, payment_method: 1, cc_name: 'Test Guy', order: order)
        expect(payment_2.sales_tax_amount).to eq 0.00
      end
    end
  end
end

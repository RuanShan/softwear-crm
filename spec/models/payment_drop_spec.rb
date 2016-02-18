require 'spec_helper'

describe PaymentDrop, payment_drop_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationship' do
    it { is_expected.to have_many(:payment_drop_payments).dependent(:destroy) }
    it { is_expected.to have_many(:payments).through(:payment_drop_payments) }
    it { is_expected.to belong_to(:store)}
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:store) }
    it { is_expected.to validate_presence_of(:cash_included) }
    it { is_expected.to validate_presence_of(:check_included) }

    context 'amount of cash dropped is different than total amount of cash' do
      before(:each) do
        allow(subject).to receive(:cash_included_matches_total_cash?) { false }
      end

      it {is_expected.to validate_presence_of(:difference_reason) }
    end
  end

  describe '#total_amount' do
    it 'returns the total of all payments for the drop'
  end

  describe '#total_amount_for_payment_method' do
    it 'returns the total of all payments that have the payment_method for the drop'

  end

end

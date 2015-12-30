require 'spec_helper'

describe PaymentDrop, payment_drop_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationship' do
    it { is_expected.to have_many(:payment_drop_payments).dependent(:destroy) }
    it { is_expected.to have_many(:payments).through(:payment_drop_payments) }
    it { is_expected.to belong_to(:store)}
    it { is_expected.to belong_to(:salesperson).class_name('User')}
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:store) }
    it { is_expected.to validate_presence_of(:salesperson) }
    it { is_expected.to validate_presence_of(:payment_drop_payments) }

    context 'amount of cash dropped is different than total amount of cash' do

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
require 'spec_helper'

describe Deposit, deposit_spec: true do
  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many :payment_drops }
    it { is_expected.to have_many(:payments).through(:payment_drops) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :payment_drops }
    it { is_expected.to validate_presence_of :depositor_id }
    it { is_expected.to validate_presence_of :cash_included }
    it { is_expected.to validate_presence_of :check_included }
    it { is_expected.to validate_presence_of :deposit_location }
    it { is_expected.to validate_presence_of :deposit_id }
    it { is_expected.to validate_presence_of :payment_drops }
  end

  context 'amount of cash deposited is different than sum of payment_drops cash' do
    before(:each) do
      allow(subject).to receive(:cash_included_matches_total_cash?) { false }
    end

    it {is_expected.to validate_presence_of(:difference_reason) }
  end

  describe '#total_amount' do
    it 'returns the total of all payments included in the drop'
  end

  describe '#total_amount_for_payment_method' do
    it 'returns the total of all payments that have the payment_method for the drop'

  end

end
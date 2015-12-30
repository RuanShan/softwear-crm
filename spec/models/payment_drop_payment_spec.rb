require 'spec_helper'

describe PaymentDropPayment, payment_drop_payment_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationship' do
    it { is_expected.to belong_to(:payment) }
    it { is_expected.to belong_to(:payment_drop) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:payment_id) }
    it { is_expected.to validate_presence_of(:payment) }
    it { is_expected.to validate_presence_of(:payment_drop) }
  end
end
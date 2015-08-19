require 'spec_helper'

describe Proof, proof_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to have_many(:mockups) }
    it { is_expected.to have_many(:artworks) }
    it { is_expected.to belong_to(:job) }
    it { is_expected.to accept_nested_attributes_for(:mockups) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:approve_by) }
    it { is_expected.to validate_presence_of(:artworks) }
    it { is_expected.to validate_presence_of(:status) }
  end
end

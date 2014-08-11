require 'spec_helper'

describe Proof, proof_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { should belong_to(:order) }
    it { should have_many(:mockups) }
    it { should have_and_belong_to_many(:artworks) }
    it { should accept_nested_attributes_for(:mockups) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:approve_by) }
    it { should validate_presence_of(:artworks) }
    it { should validate_presence_of(:status) }
  end
end

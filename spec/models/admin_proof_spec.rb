require 'spec_helper'

describe AdminProof, admin_proof_spec: true do
  context 'Associations' do
    it { is_expected.to belong_to(:order) }
  end


end

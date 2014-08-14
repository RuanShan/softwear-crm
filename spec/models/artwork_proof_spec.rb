require 'spec_helper'
include ApplicationHelper

describe ArtworkProof, artwork_proof_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artwork) }
    it { is_expected.to belong_to(:proof) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:artwork_id).scoped_to(:proof_id) }
  end
end
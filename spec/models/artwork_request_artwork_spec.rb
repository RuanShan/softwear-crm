require 'spec_helper'
include ApplicationHelper

describe ArtworkRequestArtwork, artwork_request_artwork_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artwork_request) }
    it { is_expected.to belong_to(:artwork) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:artwork_request_id).scoped_to(:artwork_id) }
  end
end
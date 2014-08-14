require 'spec_helper'
include ApplicationHelper

describe ArtworkRequestInkColor, artwork_request_ink_color_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artwork_request) }
    it { is_expected.to belong_to(:ink_color) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:artwork_request_id).scoped_to(:ink_color_id) }
  end
end
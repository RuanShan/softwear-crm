require 'spec_helper'
include ApplicationHelper

describe Artwork, artwork_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to have_one(:artwork) }
    it { is_expected.to have_one(:preview) }
    it { is_expected.to have_and_belong_to_many(:artwork_requests) }
    it { is_expected.to accept_nested_attributes_for(:artwork)}
    it { is_expected.to accept_nested_attributes_for(:preview)}
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
  end
end

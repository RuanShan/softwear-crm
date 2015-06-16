require 'spec_helper'

describe InkColor do

  it { is_expected.to be_paranoid }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    # TODO Nigel thinks the rspec shoulda matchers just aren't working with his uniqueness/scoped/deleted_at patch
    # it { is_expected.to validate_uniqueness_of(:name).scoped_to(:imprint_method) }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprint_method) }
    it { is_expected.to have_many(:artwork_requests) }
  end
end

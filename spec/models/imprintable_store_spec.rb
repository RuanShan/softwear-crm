require 'spec_helper'
include ApplicationHelper

describe ImprintableStore, imprintable_store_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprintable) }
    it { is_expected.to belong_to(:store) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:imprintable_id).scoped_to(:store_id) }
  end
end
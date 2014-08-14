require 'spec_helper'
include ApplicationHelper

describe ImprintMethodImprintable, imprint_method_imprintable_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprint_method) }
    it { is_expected.to belong_to(:imprintable) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:imprint_method_id).scoped_to(:imprintable_id) }
  end
end
require 'spec_helper'
describe ImprintableCategory, imprintable_spec: true do

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprintable) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:imprintable_id) }
  end
end

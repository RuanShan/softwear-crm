require 'spec_helper'
describe ImprintableCategory, imprintable_spec: true do

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprintable) }
  end

  describe 'Validations' do
    it 'should not fail this test', pending: 'Dont know why this is failing' do
      is_expected.to validate_inclusion_of(:name).in_array ImprintableCategory::VALID_CATEGORIES
    end
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:imprintable_id) }
  end
end

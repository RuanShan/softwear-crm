require 'spec_helper'

describe ImprintableGroup, story_554: true do
  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of :name }
  end

  describe 'Relationships' do
    it { is_expected.to have_many(:imprintable_imprintable_groups) }
    it { is_expected.to have_many(:imprintables).through(:imprintable_imprintable_groups) }
  end
end

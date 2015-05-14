require 'spec_helper'

describe ImprintableGroup, story_554: true do
  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of :name }
  end

  describe 'Relationships' do
    it { is_expected.to have_many(:imprintable_imprintable_groups) }
    it { is_expected.to have_many(:imprintables).through(:imprintable_imprintable_groups) }
  end

  describe '#default_imprintable_for_tier', story_567: true do
    subject { ImprintableGroup.create(name: 'test group', description: 'yeah') }
    let!(:default_imprintable) { create(:valid_imprintable) }
    let!(:other_imprintable) { create(:valid_imprintable) }

    before do
      iig1 = ImprintableImprintableGroup.new
      iig1.tier    = Imprintable::TIER.good
      iig1.default = true

      iig1.imprintable = default_imprintable
      iig1.imprintable_group = subject
      iig1.save!

      iig2  = ImprintableImprintableGroup.new
      iig2.tier   = Imprintable::TIER.good
      iig2.default = false

      iig2.imprintable = other_imprintable
      iig2.imprintable_group = subject
      iig2.save!
    end

    it 'returns the default imprintable for a given tier' do
      expect(subject.default_imprintable_for_tier(Imprintable::TIER.good))
        .to eq default_imprintable
    end
  end
end

require 'spec_helper'

describe ImprintableImprintableGroup, story_554: true do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :tier }

    context 'when default is false' do
      subject { build(:imprintable_imprintable_group, tier: 3, default: false) }

      it { is_expected.to_not validate_uniqueness_of(:default).scoped_to([:imprintable_group_id, :tier]).with_message('Only one default for each tier-group pair') }
    end
  end

  describe 'Relationships' do
    it { is_expected.to belong_to :imprintable_group }
    it { is_expected.to belong_to :imprintable }
  end
end

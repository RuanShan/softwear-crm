require 'spec_helper'

describe ImprintMethod, imprint_method_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many(:ink_colors) }
    it { is_expected.to have_many(:print_locations) }
    it { is_expected.to have_many(:imprintables) }

    it { is_expected.to accept_nested_attributes_for(:print_locations) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe '#ink_color_names=', story_862: true do
    subject { create :valid_imprint_method }

    it 'adds the given colors to ink_colors, by name' do
      subject.ink_color_names = ['Red', 'Blue', 'Green']
      expect(InkColor.where(name: 'Red')).to exist
      expect(InkColor.where(name: 'Blue')).to exist
      expect(InkColor.where(name: 'Green')).to exist
      expect(subject.ink_colors.pluck(:name) - ['Red', 'Blue', 'Green']).to be_empty
    end

    context 'when one of the given colors already exists' do
      let!(:yellow) { create :ink_color, name: 'Yellow' }

      it 'uses the existing one instead of creating a new one' do
        subject.ink_color_names = ['Red', 'Yellow']
        expect(subject.ink_colors).to include yellow
      end
    end

    context 'when one of its existing ink colors is not included in the new list' do
      let!(:yellow) { create :ink_color, name: 'Yellow', imprint_methods: [subject] }

      it 'removes the excluded ones' do
        expect(subject.ink_colors).to include yellow # sanity
        subject.ink_color_names = ['Red']
        expect(subject.reload.ink_colors).to_not include yellow
        expect(subject.ink_colors.pluck(:name)).to_not include 'Yellow'
        expect(subject.ink_colors.pluck(:name)).to include 'Red'
      end
    end
  end
end

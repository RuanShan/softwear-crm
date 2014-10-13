require 'spec_helper'

describe Imprint, imprint_spec: true do
  let(:imprint) { create :valid_imprint }

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to :job }
    it { is_expected.to belong_to :print_location }
    it { is_expected.to have_one(:imprint_method).through(:print_location) }
    it { is_expected.to have_one(:order).through(:job) }
    context 'when testing story-189', story_189: true do
      it { is_expected.to have_many :name_numbers }
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :job }
    it { is_expected.to validate_presence_of :print_location }
    # FIXME why doesn't this work?
    # it { is_expected.to validate_uniqueness_of(:print_location).scoped_to(:job_id) }
  end

  describe 'Scopes' do
    describe 'with_name_number', name_number: true do
      let!(:imprint_1) { create :imprint_with_name_number }
      let!(:imprint_2) { create :imprint_with_name_number, has_name_number: false }
      let!(:imprint_3) { create :valid_imprint }

      subject { Imprint.with_name_number }

      it 'includes only imprints where has_name_number=true and name_number is not empty' do
        expect(subject).to exist
        expect(subject).to include imprint_1
        expect(subject).to_not include imprint_2
        expect(subject).to_not include imprint_3
      end
    end
  end

  describe '#name' do
    before do
      allow(subject).to receive(:imprint_method) { build_stubbed(:blank_imprint_method, name: 'IM name') }
      allow(subject).to receive(:print_location) { build_stubbed(:blank_print_location, name: 'PL name') }
    end

    it 'returns a string of imprint_method.name - print_location.name' do
      expect(subject.name).to eq('IM name - PL name')
    end
  end
end
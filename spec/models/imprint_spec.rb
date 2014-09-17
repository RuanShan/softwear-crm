require 'spec_helper'

describe Imprint, imprint_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to :job }
    it { is_expected.to belong_to :print_location }
    it { is_expected.to belong_to :name_number }
    it { is_expected.to have_one(:imprint_method).through(:print_location) }
    it { is_expected.to have_one(:order).through(:job) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :job }
    it { is_expected.to validate_presence_of :print_location }
    # FIXME why doesn't this work?
    # it { is_expected.to validate_uniqueness_of(:print_location).scoped_to(:job_id) }
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

  describe '#destroy' do
    it 'destroys its name_number' do
      name_number = double('Name Number')
      expect(name_number).to receive(:destroy)
      expect(subject).to receive(:name_number).and_return name_number

      subject.destroy
    end
  end

  describe '#has_name_number=' do
    context 'true' do
      it 'validates presence of name_number next save' do
        subject.has_name_number = true
        expect(subject.name_number_id).to be_nil
        expect(subject).to_not be_valid
      end
    end
    context 'false' do
      it 'empties name_number next save' do
        subject.update_attributes name_number_id: 1
        subject.has_name_number = false

        expect(subject).to be_valid
        expect(subject.save).to be_truthy
        expect(subject.name_number_id).to be_nil
      end
    end
  end

  describe '#has_name_number?' do
    context 'when name_number_id is nil' do
      it 'returns false' do
        allow(subject).to receive(:name_number_id).and_return nil
        expect(subject.has_name_number?).to eq false
      end
    end

    context 'when name_number is a non-empty string' do
      it 'returns true' do
        allow(subject).to receive(:name_number_id).and_return 1
        expect(subject.has_name_number?).to eq true
      end
    end
  end
end
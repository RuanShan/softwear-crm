require 'spec_helper'

describe CoordinateImprintable, imprintable_spec: true, coordinate_imprintable_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:coordinate).class_name('Imprintable') }
    it { is_expected.to belong_to(:imprintable) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:coordinate) }
    it { is_expected.to validate_presence_of(:imprintable) }
  end

  describe '#add_mirror' do
    context 'there are 2 different imprintables' do
      let!(:imprintable_one) { build_stubbed(:blank_imprintable) }
      let!(:imprintable_two) { build_stubbed(:blank_imprintable) }

      it 'creates a mirrored version of the imprintable' do
        CoordinateImprintable.create(coordinate: imprintable_one, imprintable: imprintable_two)
        expect(CoordinateImprintable.find_by(coordinate: imprintable_two)).to_not be_nil
      end
    end
  end

  context 'there is a coordinate-imprintable' do
    let!(:coordinate) { create(:coordinate_imprintable) }

    describe '#update_mirror' do
      context 'there is another imprintable' do
        let!(:imprintable) { create(:valid_imprintable) }

        it 'updates both coordinates with the correct information' do
          coordinate.imprintable.id = imprintable.id
          coordinate.save!
          expect(CoordinateImprintable.where(imprintable: imprintable)).to exist
          expect(CoordinateImprintable.where(coordinate: imprintable)).to exist
        end
      end
    end

    describe '#destroy_mirror' do
      it 'destroys both the mirror and the original' do
        coordinate.destroy
        expect(CoordinateImprintable.find_by(imprintable: coordinate.imprintable)).to be_nil
        expect(CoordinateImprintable.find_by(coordinate: coordinate.imprintable)).to be_nil
      end
    end
  end
end
require 'spec_helper'

describe CoordinateImprintable, imprintable_spec: true do
  describe 'Relationships' do
    it { should belong_to(:imprintable) }
    it { should belong_to(:coordinate).class_name('Imprintable') }
  end

  describe 'Validations' do
    it { should validate_presence_of(:imprintable) }
    it { should validate_presence_of(:coordinate) }
  end

  describe '#add_mirror' do
    context 'there are 2 different imprintables' do
      let!(:imprintable_one) { create(:valid_imprintable) }
      let!(:imprintable_two) { create(:valid_imprintable) }

      it 'should add create a mirrored version of the imprintable' do
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

        it 'should update both coordinates with the correct information' do
          coordinate.imprintable.id = imprintable.id
          coordinate.save!
          expect(CoordinateImprintable.where(imprintable: imprintable)).to exist
          expect(CoordinateImprintable.where(coordinate: imprintable)).to exist
        end
      end
    end

    describe '#destroy_mirror' do
      it 'should destroy both the mirror and the original' do
        coordinate.destroy
        expect(CoordinateImprintable.find_by(imprintable: coordinate.imprintable)).to be_nil
        expect(CoordinateImprintable.find_by(coordinate: coordinate.imprintable)).to be_nil
      end
    end
  end
end

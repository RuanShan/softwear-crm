require 'spec_helper'
describe ImprintableVariant, imprintable_variant_spec: true do

  describe 'Relationships' do
    it { should belong_to(:imprintable) }
    it { should belong_to(:size) }
    it { should belong_to(:color) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:imprintable) }
    it { should validate_presence_of(:size) }
    it { should validate_presence_of(:color) }
  end

  describe 'Scopes' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }
    let!(:deleted_imprintable_variant) { create(:valid_imprintable_variant, deleted_at: Time.now) }

    describe 'default_scope' do
      it 'includes only imprintable variants where deleted_at is nil' do
        expect(ImprintableVariant.all).to eq([imprintable_variant])
      end
    end

    describe 'deleted' do
      it 'includes only imprintables variants where deleted_at is not nil' do
        expect(ImprintableVariant.all).to eq([imprintable_variant])
      end
    end
  end

  context 'There is a valid imprintable_variant' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }

    describe '#full_name' do
      it 'returns "imprintable.brand.name imprintable.catalog_no size.name color.name"' do
        expect(imprintable_variant.full_name).to eq("#{ imprintable_variant.imprintable.brand.name } #{ imprintable_variant.imprintable.style.catalog_no } #{ imprintable_variant.size.name } #{ imprintable_variant.color.name }")
      end
    end

    describe '#brand' do
      it 'returns the right brand' do
        expect(imprintable_variant.brand).to eq(imprintable_variant.imprintable.brand)
      end
    end

    describe '#style' do
      it 'returns the right style' do
        expect(imprintable_variant.style).to eq(imprintable_variant.imprintable.style)
      end
    end

    describe '#destroyed?' do
      it 'returns true if deleted_at is set' do
        imprintable_variant.deleted_at = Time.now
        expect(imprintable_variant.destroyed?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'sets deleted_at to the current time' do
        imprintable_variant.destroy
        expect(imprintable_variant.deleted_at).to_not be_nil
      end
    end
  end
end

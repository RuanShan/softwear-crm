require 'spec_helper'
describe ImprintableVariant, imprintable_variant_spec: true do

  describe 'Relationships' do
    it {should belong_to(:imprintable)}
    it {should belong_to(:size)}
    it {should belong_to(:color)}
  end

  describe 'Validations' do
    it {should validate_presence_of(:imprintable)}
    it {should validate_presence_of(:size)}
    it {should validate_presence_of(:color)}
  end

  describe 'Scopes' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant)}
    let!(:deleted_imprintable_variant) { create(:valid_imprintable_variant, deleted_at: Time.now)}

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

  describe '#full_name' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant)}
    it 'returns "imprintable.brand.name imprintable.catalog_no size.name color.name"' do
      expect(imprintable_variant.full_name).to eq("#{imprintable_variant.imprintable.brand.name} #{imprintable_variant.imprintable.style.catalog_no} #{imprintable_variant.size.name} #{imprintable_variant.color.name}")
    end
  end

  describe '#destroyed?' do
    let! (:imprintable_variant) { create(:valid_imprintable_variant, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(imprintable_variant.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant)}

    it 'sets deleted_at to the current time' do
      updated_at = imprintable_variant.updated_at
      imprintable_variant.destroy!
      expect(imprintable_variant.deleted_at).to_not be_nil
      expect(imprintable_variant.updated_at).to eq(updated_at)
    end
  end
end

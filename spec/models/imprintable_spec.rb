require 'spec_helper'

describe Imprintable, imprintable_spec: true do
  describe 'Relationship' do
    it { should belong_to(:style) }
    it { should have_one(:brand).through(:style) }
    it { should have_many(:imprintable_variants) }
    it { should have_many(:colors).through(:imprintable_variants) }
    it { should have_many(:sizes).through(:imprintable_variants) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:style) }
    it { should ensure_inclusion_of(:sizing_category).in_array Imprintable::SIZING_CATEGORIES }
  end

  describe 'Scopes' do
    let!(:imprintable) { create(:valid_imprintable) }
    let!(:deleted_imprintable) { create(:valid_imprintable, deleted_at: Time.now) }

    describe 'default_scope' do
      it 'includes only imprintables where deleted_at is nil' do
        expect(Imprintable.all).to eq([imprintable])
      end
    end

    describe 'deleted' do
      it 'includes only imprintables where deleted_at is not nil' do
        expect(Imprintable.all).to eq([imprintable])
      end
    end
  end

  describe '#name' do
    let!(:imprintable) { create(:valid_imprintable) }
    it 'returns a string of the style.catalog_no and style.name' do
      expect(imprintable.name).to eq("#{ imprintable.style.catalog_no } #{ imprintable.style.name }")
    end
  end

  describe 'find_variants' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }
    it 'returns the correct variant' do
      expect(imprintable_variant.imprintable.find_variants.to_a[0]).to eq(imprintable_variant)
    end
  end

  describe 'create_variants_hash' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }
    it 'returns the expect values for size_variants, color_variants, and variants_array' do
      variants_hash = imprintable_variant.imprintable.create_variants_hash
      expect(variants_hash[:size_variants][0].id).to eq(imprintable_variant.size_id)
      expect(variants_hash[:color_variants][0].id).to eq(imprintable_variant.color_id)
      expect(variants_hash[:variants_array][0].id).to eq(imprintable_variant.id)
    end
  end

  describe '#destroyed?' do
    let! (:imprintable) { create(:valid_imprintable, deleted_at: Time.now) }

    it 'returns true if deleted_at is set' do
      expect(imprintable.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:imprintable) { create(:valid_imprintable) }

    it 'sets deleted_at to the current time' do
      imprintable.destroy
      expect(imprintable.deleted_at).to_not be_nil
    end
  end
end

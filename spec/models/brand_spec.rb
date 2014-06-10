require 'spec_helper'

describe Brand, brand_spec: true do
  describe 'Relationships' do
    it { should have_many(:styles) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should validate_presence_of(:sku) }
    it { should ensure_length_of(:sku).is_equal_to(2) }

    it { should validate_uniqueness_of(:sku) }
  end

  describe 'Scopes' do
    let!(:brand) { create(:valid_brand) }
    let!(:deleted_brand) { create(:valid_brand, deleted_at: Time.now, name: 'Deleted') }

    describe 'default_scope' do
      it 'includes only brands where deleted_at is nil' do
        expect(Brand.all).to eq([brand])
      end
    end

    describe 'deleted' do
      it 'includes only brands where deleted_at is not nil' do
        expect(Brand.all).to eq([brand])
      end
    end
  end

  describe '#destroyed?' do
    let! (:brand) { create(:valid_brand, deleted_at: Time.now) }

    it 'returns true if deleted_at is set' do
      expect(brand.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:brand) { create(:valid_brand) }

    it 'sets deleted_at to the current time' do
      brand.destroy
      expect(brand.deleted_at).to_not be_nil
    end
  end
end

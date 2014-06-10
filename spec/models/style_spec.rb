require 'spec_helper'

describe Style, style_spec: true do

  describe 'Relationships' do
    it { should belong_to(:brand) }
    it { should have_one(:imprintable) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should validate_presence_of(:sku) }
    it { should validate_uniqueness_of(:sku) }
    it { should ensure_length_of(:sku).is_equal_to(2) }

    it { should validate_presence_of(:catalog_no) }
    it { should validate_uniqueness_of(:catalog_no) }

    it { should validate_presence_of(:brand) }
  end

  describe 'Scopes' do
    let!(:style) { create(:valid_style) }
    let!(:deleted_style) { create(:valid_style, deleted_at: Time.now, name: 'Deleted') }

    describe 'default_scope' do
      it 'includes only styles where deleted_at is nil' do
        expect(Style.all).to eq([style])
      end
    end

    describe 'deleted' do
      it 'includes only styles where deleted_at is not nil' do
        expect(Style.all).to eq([style])
      end
    end
  end

  describe '#destroyed?' do
    let! (:style) { create(:valid_style, deleted_at: Time.now) }

    it 'returns true if deleted_at is set' do
      expect(style.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:style) { create(:valid_style) }

    it 'sets deleted_at to the current time' do
      style.destroy
      expect(style.deleted_at).to_not be_nil
    end
  end

  describe '#find_brand' do
    let!(:style) { create(:valid_style) }

    it 'returns the correct brand_id' do
      brand = style.find_brand
      expect(brand.id).to eq(style.brand.id)
    end
  end
end

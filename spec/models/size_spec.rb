require 'spec_helper'

describe Size, size_spec: true do
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sku)}
    it { should validate_uniqueness_of(:name)}
    it { should validate_uniqueness_of(:sku)}
  end

  describe 'Scopes' do
    let!(:size) { create(:valid_size)}
    let!(:deleted_size) { create(:valid_size, deleted_at: Time.now, name: 'Deleted')}

    describe 'default_scope' do
      it 'includes only sizes where deleted_at is nil' do
        expect(Size.all).to eq([size])
      end
    end

    describe 'deleted' do
      it 'includes only sizes where deleted_at is not nil' do
        expect(Size.all).to eq([size])
      end
    end
  end

  describe '#destroyed?' do
    let! (:size) { create(:valid_size, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(size.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:size) { create(:valid_size)}

    it 'sets deleted_at to the current time' do
      updated_at = size.updated_at
      size.destroy!
      expect(size.deleted_at).to_not be_nil
      expect(size.updated_at).to eq(updated_at)
    end
  end
end
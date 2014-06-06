require 'spec_helper'

describe Color, color_spec: true do
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sku)}
    it { should validate_uniqueness_of(:name)}
    it { should validate_uniqueness_of(:sku)}
  end

  describe 'Scopes' do
    let!(:color) { create(:valid_color)}
    let!(:deleted_color) { create(:valid_color, deleted_at: Time.now, name: 'Deleted')}

    describe 'default_scope' do
      it 'includes only colors where deleted_at is nil' do
        expect(Color.all).to eq([color])
      end
    end

    describe 'deleted' do
      it 'includes only colors where deleted_at is not nil' do
        expect(Color.all).to eq([color])
      end
    end
  end

  describe '#destroyed?' do
    let! (:color) { create(:valid_color, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(color.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:color) { create(:valid_color)}

    it 'sets deleted_at to the current time' do
      updated_at = color.updated_at
      color.destroy!
      expect(color.deleted_at).to_not be_nil
      expect(color.updated_at).to eq(updated_at)
    end
  end
end
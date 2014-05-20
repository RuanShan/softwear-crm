require 'spec_helper'

describe Imprintable do
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description)}
  end

  describe 'Scopes' do
    let!(:imprintable) { create(:valid_imprintable)}
    let!(:deleted_imprintable) { create(:valid_imprintable, deleted_at: Time.now, name: 'Deleted')}

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

  describe '#destroyed?' do
    let! (:imprintable) { create(:valid_imprintable, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(imprintable.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:imprintable) { create(:valid_imprintable)}

    it 'sets deleted_at to the current time' do
      updated_at = imprintable.updated_at
      imprintable.destroy!
      expect(imprintable.deleted_at).to_not be_nil
      expect(imprintable.updated_at).to eq(updated_at)
    end
  end
end
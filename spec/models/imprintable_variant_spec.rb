require 'spec_helper'

describe 'Scopes' do
  let!(:imprintable_variant) { create(:valid_imprintable_variant)}
  let!(:deleted_imprintable_variant) { create(:valid_imprintable_variant, deleted_at: Time.now, imprintable_id: 'Deleted')}

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

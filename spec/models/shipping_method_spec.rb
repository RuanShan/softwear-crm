require 'spec_helper'

describe ShippingMethod do
  describe 'Validations' do
    it { should validate_uniqueness_of(:name) }
    it { should allow_value('http://www.foo.com', 'http://www.foo.com/shipping').for(:tracking_url) }
    it { should_not allow_value('bad_url.com').for(:tracking_url) }
  end

  describe 'Scopes' do
    let!(:shipping_method) { create(:valid_shipping_method)}
    let!(:deleted_shipping_method) { create(:valid_shipping_method, deleted_at: Time.now, name: 'Deleted')}

    describe 'default_scope' do
      it 'includes only shipping_methods where deleted_at is nil' do
        expect(ShippingMethod.all).to eq([shipping_method])
      end
    end

    describe 'deleted' do
      it 'includes only shipping_methods where deleted_at is not nil' do
        expect(ShippingMethod.all).to eq([shipping_method])
      end
    end
  end

  describe '#destroyed?' do
    let!(:shipping_method) { create(:valid_shipping_method, deleted_at: Time.now)}

    it 'returns true if deleted_at is set' do
      expect(shipping_method.destroyed?).to be_truthy
    end
  end

  describe '#destroy' do
    let!(:shipping_method) { create(:valid_shipping_method)}

    it 'sets deleted_at to the current time' do
      shipping_method.destroy
      expect(shipping_method.deleted_at).to_not be_nil
    end
  end

  describe '#destroy!' do
    let!(:shipping_method) { create(:valid_shipping_method)}

    it 'sets deleted_at to the current time without modifying updated_at' do
      updated_at = shipping_method.updated_at
      shipping_method.destroy!
      expect(shipping_method.deleted_at).to_not be_nil
      expect(shipping_method.updated_at).to eq(updated_at)
    end
  end
end

require 'spec_helper'

describe Brand, brand_spec: true do
  it_behaves_like 'retailable'

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many :imprintables }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }

    context 'if retail' do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(true) }
      it { is_expected.to ensure_length_of(:sku).is_equal_to(2) }
    end

    context 'if not retail' do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(false) }
      it { is_expected.to_not ensure_length_of(:sku).is_equal_to(2) }
    end
  end

  describe 'Scopes' do
    context 'when there are two brands' do
      let!(:brand_one) { create(:valid_brand, name: 'Urban Outfitters') }
      let!(:brand_two) { create(:valid_brand, name: 'American Apparel') }

      it 'orders so the first brand is brand_two' do
        expect(Brand.first).to eq(brand_two)
      end

      it 'orders so the last brand is brand_one' do
        expect(Brand.last).to eq(brand_one)
      end
    end
  end
end

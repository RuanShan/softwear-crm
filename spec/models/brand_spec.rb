require 'spec_helper'

describe Brand, brand_spec: true do
  describe 'Relationships' do
    it { should have_many(:imprintables) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }


    context "if retail" do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(true)}
      it { should ensure_length_of(:sku).is_equal_to(2) }
    end

    context "if not retail" do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(false)}
      it { should_not ensure_length_of(:sku).is_equal_to(2) }
    end

  end

  describe 'Scopes' do
    context 'there are two brands' do
      let!(:brand_one) { create(:valid_brand, name: 'Urban Outfitters') }
      let!(:brand_two) { create(:valid_brand, name: 'American Apparel') }

      it 'should order the brands by name' do
        expect(Brand.first).to eq(brand_two)
        expect(Brand.last).to eq(brand_one)
      end
    end
  end

  # it_behaves_like 'retailable'

end

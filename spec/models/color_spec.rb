require 'spec_helper'

describe Color, color_spec: true do

  it_behaves_like 'retailable'

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many(:imprintable_variants).dependent(:destroy) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    context 'if retail' do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(true) }

      it { is_expected.to ensure_length_of(:sku).is_equal_to(3) }
    end

    context 'if not retail' do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(false) }

      it { is_expected.to_not ensure_length_of(:sku).is_equal_to(3) }
    end
  end

  describe 'Scopes' do
    context 'there are two colors' do
      let!(:color_one) { create(:valid_color, name: 'Red') }
      let!(:color_two) { create(:valid_color, name: 'Blue') }

      it 'orders the colors by name' do
        expect(Color.first).to eq(color_two)
        expect(Color.last).to eq(color_one)
      end
    end
  end
end
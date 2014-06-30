require 'spec_helper'

describe Color, color_spec: true do
  describe 'Relationships' do
    it { should have_many(:imprintable_variants).dependent(:destroy) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    context "if retail" do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(true)}
      it { should ensure_length_of(:sku).is_equal_to(3) }
    end

    context "if not retail" do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(false)}
      it { should_not ensure_length_of(:sku).is_equal_to(3) }
    end
  end

  describe 'Scopes' do
    context 'there are two colors' do
      let!(:color_one) { create(:valid_color, name: 'Red') }
      let!(:color_two) { create(:valid_color, name: 'Blue') }

      it 'should order the colors by name' do
        expect(Color.first).to eq(color_two)
        expect(Color.last).to eq(color_one)
      end
    end
  end

  it_behaves_like 'retailable'

end

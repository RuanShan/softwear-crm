require 'spec_helper'

describe Size, size_spec: true do

  it_behaves_like 'retailable'

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to have_many(:imprintable_variants).dependent(:destroy) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    context 'if retail' do
      before do
        allow(subject).to receive_message_chain(:is_retail?).and_return(true)
      end
      it { is_expected.to ensure_length_of(:sku).is_equal_to(2) }
    end

    context 'if not retail' do
      before do
        allow(subject).to receive_message_chain(:is_retail?).and_return(false)
      end
      it { is_expected.to_not ensure_length_of(:sku).is_equal_to(2) }
    end

    it { is_expected.to validate_uniqueness_of(:sort_order) }
  end

end

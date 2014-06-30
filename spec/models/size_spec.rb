require 'spec_helper'

describe Size, size_spec: true do
  describe 'Relationships' do
    it { should have_many(:imprintable_variants).dependent(:destroy) }
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

    it { should validate_uniqueness_of(:sort_order) }
  end

  it_behaves_like 'retailable'
end

require 'spec_helper'

describe Size, size_spec: true do
  describe 'Relationships' do
    it { should have_many(:imprintable_variants) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should validate_presence_of(:sku) }
    it { should validate_uniqueness_of(:sku) }
    it { should ensure_length_of(:sku).is_equal_to(2) }

    it { should validate_uniqueness_of(:sort_order) }
  end
end

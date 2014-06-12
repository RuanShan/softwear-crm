require 'spec_helper'
describe ImprintableVariant, imprintable_variant_spec: true do

  describe 'Relationships' do
    it { should belong_to(:imprintable) }
    it { should belong_to(:size) }
    it { should belong_to(:color) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:imprintable) }
    it { should validate_presence_of(:size) }
    it { should validate_presence_of(:color) }
  end

  context 'There is a valid imprintable_variant' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }

    describe '#full_name' do
      it 'returns "imprintable.brand.name imprintable.catalog_no size.name color.name"' do
        expect(imprintable_variant.full_name).to eq("#{ imprintable_variant.imprintable.brand.name } #{ imprintable_variant.imprintable.style.catalog_no } #{ imprintable_variant.color.name } #{ imprintable_variant.size.name }")
      end
    end

    describe '#brand' do
      it 'returns the brand associated with the imprintable associated with the imprintable variant' do
        expect(imprintable_variant.brand).to eq(imprintable_variant.imprintable.brand)
      end
    end

    describe '#style' do
      it 'returns the style associated with the imprintable associated with the imprintable variant' do
        expect(imprintable_variant.style).to eq(imprintable_variant.imprintable.style)
      end
    end
  end
end

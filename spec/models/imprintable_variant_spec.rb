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
    it { should validate_uniqueness_of(:color_id).scoped_to(:size_id) }
  end

  context 'There is a valid imprintable_variant' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }

    describe '#full_name' do
      it 'returns "imprintable.brand.name imprintable.catalog_no size.name color.name"' do
        expect(imprintable_variant.full_name).to eq("#{ imprintable_variant.imprintable.brand.name } #{ imprintable_variant.imprintable.style_catalog_no } #{ imprintable_variant.color.name } #{ imprintable_variant.size.name }")
      end
    end

    describe '#description' do
      it 'returns the description of the imprintable' do
        expect(imprintable_variant.description).to eq(imprintable_variant.imprintable.description)
      end
    end

    describe '#name' do
      it 'returns "color.name imprintable.name"' do
        expect(imprintable_variant.name).to eq("#{ imprintable_variant.color.name } #{ imprintable_variant.imprintable.name }")
      end
    end

    describe '#style_name' do
      it 'returns the associated style\'s name' do
        expect(imprintable_variant.style_name).to eq(imprintable_variant.imprintable.style_name)
      end
    end

    describe '#style_catalog_no' do
      it 'returns the associated style\'s catalog number' do
        expect(imprintable_variant.style_catalog_no).to eq(imprintable_variant.imprintable.style_catalog_no)
      end
    end

    describe '#brand' do
      it 'returns the brand associated with the imprintable associated with the imprintable variant' do
        expect(imprintable_variant.brand).to eq(imprintable_variant.imprintable.brand)
      end
    end
  end
end

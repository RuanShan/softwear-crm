require 'spec_helper'

describe ImprintableVariant, imprintable_variant_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:color) }
    it { is_expected.to belong_to(:imprintable) }
    it { is_expected.to belong_to(:size) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:color) }
    it { is_expected.to validate_uniqueness_of(:color_id).scoped_to([:size_id, :imprintable_id]) }
    it { is_expected.to validate_presence_of(:imprintable) }
    it { is_expected.to validate_presence_of(:size) }
  end

  context 'There is a valid imprintable_variant' do
    let!(:imprintable_variant) { build_stubbed(:blank_imprintable_variant,
                                                 imprintable: build_stubbed(:blank_imprintable, brand: build_stubbed(:blank_brand)),
                                                 color: build_stubbed(:blank_color),
                                                 size: build_stubbed(:blank_size)) }

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

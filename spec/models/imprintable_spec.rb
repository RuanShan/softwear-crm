require 'spec_helper'

describe Imprintable, imprintable_spec: true do
  describe 'Relationship' do
    it { should belong_to(:style) }
    it { should have_one(:brand).through(:style) }
    it { should have_many(:imprintable_variants) }
    it { should have_many(:colors).through(:imprintable_variants) }
    it { should have_many(:sizes).through(:imprintable_variants) }
    it { should have_and_belong_to_many(:coordinates) }
    it { should have_and_belong_to_many(:sample_locations) }
    it { should have_and_belong_to_many(:compatible_imprint_methods) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:style) }
    it { should ensure_inclusion_of(:sizing_category).in_array Imprintable::SIZING_CATEGORIES }
  end

  describe '#name' do
    let!(:imprintable) { create(:valid_imprintable) }
    it 'returns a string of the style.catalog_no and style.name' do
      expect(imprintable.name).to eq("#{ imprintable.style.catalog_no } #{ imprintable.style.name }")
    end
  end

  describe '#description' do
    let!(:imprintable) { create(:valid_imprintable) }
    it 'returns the description for the associated style' do
      expect(imprintable.description).to eq("#{imprintable.style.description}")
    end
  end

  describe 'find_variants' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }
    it 'returns the variant that is associated with the imprintable that it is called on' do
      expect(imprintable_variant.imprintable.find_variants.to_a[0]).to eq(imprintable_variant)
    end
  end

  describe 'create_variants_hash' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }
    it 'returns the hashes that contain the size_id, color_id, and id of the associated imprintable_variant' do
      variants_hash = imprintable_variant.imprintable.create_variants_hash
      expect(variants_hash[:size_variants][0].id).to eq(imprintable_variant.size_id)
      expect(variants_hash[:color_variants][0].id).to eq(imprintable_variant.color_id)
      expect(variants_hash[:variants_array][0].id).to eq(imprintable_variant.id)
    end
  end
end

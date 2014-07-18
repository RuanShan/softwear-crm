require 'spec_helper'

describe ImprintableHelper, imprintable_helper_spec: true do

  describe 'table_entries' do
    context 'there are multiple entries in a table' do
      let!(:imprintable_one) { create(:valid_imprintable) }
      let!(:imprintable_two) { create(:valid_imprintable) }
      it 'returns a list of names separated by commas' do
        expect(table_entries(Imprintable.all)).to eq("#{imprintable_one.name.to_s}, #{imprintable_two.name.to_s}")
      end
    end
  end

  describe 'display_sizes' do
    context 'there are no associated sizes' do
      let!(:imprintable) { create(:valid_imprintable) }
      it 'returns a string saying there are no sizes available' do
        expect(display_sizes(imprintable)).to eq('There are no sizes available')
      end
    end

    context 'there is exactly 1 associated size' do
      let!(:imprintable_variant) { create(:valid_imprintable_variant) }
      it 'returns only the display value of the associated size' do
        expect(display_sizes(imprintable_variant.imprintable)).to eq(imprintable_variant.size.display_value)
      end
    end

    context 'there are more than 1 associated sizes' do

      it 'returns the first and last display value separated by a dash' do
        imprintable_variant_one = create(:valid_imprintable_variant)
        imprintable_variant_two = create(:valid_imprintable_variant)
        imprintable_variant_three = create(:valid_imprintable_variant)
        imprintable = create(:valid_imprintable)
        imprintable_variant_one.imprintable_id = imprintable.id
        imprintable_variant_two.imprintable_id = imprintable.id
        imprintable_variant_three.imprintable_id = imprintable.id
        imprintable_variant_one.save
        imprintable_variant_two.save
        imprintable_variant_three.save
        expect(display_sizes(imprintable)).to eq("#{imprintable_variant_one.size.display_value} - #{imprintable_variant_three.size.display_value}")
      end
    end
  end
end

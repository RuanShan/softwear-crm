require 'spec_helper'

describe ImprintableHelper, imprintable_helper_spec: true do

  describe '#table_entries' do
    context 'there are multiple entries in a table' do
      let!(:imprintable_one) { build_stubbed(:valid_imprintable) }

      it 'returns a list of names separated by commas' do
        expect(imprintable_one).to receive(:name)
          .at_least(2).times.and_return('brand_name')
        imprintable_array = [imprintable_one, imprintable_one]
        name_string = "#{imprintable_one.name.to_s}, #{imprintable_one.name.to_s}"
        expect(table_entries(imprintable_array)).to eq(name_string)
      end
    end
  end

  describe '#display_sizes' do
    let!(:imprintable) { build_stubbed(:valid_imprintable) }

    context 'there are no associated sizes' do
      it 'returns a string saying there are no sizes available' do
        expect(display_sizes(imprintable)).to eq('There are no sizes available')
      end
    end

    context 'there is exactly one associated size' do
      it 'returns only the display value of the associated size' do
        expect(imprintable).to receive(:sizes)
          .at_least(3).times.and_return([build_stubbed(:valid_size)])
        sizes = imprintable.sizes
        expect(display_sizes(imprintable)).to eq(sizes.first.display_value)
      end
    end

    context 'there are three associated sizes' do
      it 'returns the first and last display value separated by a dash' do
        expect(imprintable).to receive(:sizes).at_least(4).times.and_return(
          [
            build_stubbed(:valid_size),
            build_stubbed(:valid_size),
            build_stubbed(:valid_size)
          ])
        sizes = imprintable.sizes
        display_vals = "#{sizes.first.display_value} - #{sizes.last.display_value}"
        expect(display_sizes(imprintable)).to eq(display_vals)
      end
    end
  end
end

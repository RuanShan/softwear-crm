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

  describe 'pricing table manipulation', story_508: true, pending: 'NO MORE PRICING TABLE' do
    let!(:imprintable_1) { create :valid_imprintable, xxl_price: nil, xxxxxxl_price: nil, xxxxxl_price: nil }
    let!(:imprintable_2) { create :valid_imprintable, xxxxl_price: nil, xxxxxxl_price: nil, xxxxxl_price: nil }

    let!(:imprintable_3) { create :valid_imprintable, xxxxxxl_price: nil, xxxxxl_price: nil }
    let!(:imprintable_4) { create :valid_imprintable, xxxxl_price: nil, xxxxxxl_price: nil, xxxxxl_price: nil }

    let(:pricing_array_1) { [imprintable_1.pricing_hash(2.2), imprintable_2.pricing_hash(2.2)] }
    let(:pricing_array_2) { [imprintable_3.pricing_hash(5.1), imprintable_4.pricing_hash(7.2)] }
    let(:pricing_groups) { { group_1: pricing_array_1, group_2: pricing_array_2 } }

    describe '#omit_unused_prices_from' do
      context 'given a pricing array with redundantly missing sizes' do
        it 'removes those sizes' do
          expect(pricing_array_1.first[:prices][:xxxxxxl_price]).to eq 'n/a'
          expect(pricing_array_1.last[:prices][:xxxxxxl_price]).to eq 'n/a'
          expect(pricing_array_2.first[:prices][:xxxxxxl_price]).to eq 'n/a'
          expect(pricing_array_2.last[:prices][:xxxxxxl_price]).to eq 'n/a'

          new_groups = omit_unused_prices_from pricing_groups
          new_array = new_groups[:group_1]

          expect(new_array.first[:prices][:xxxxxxl_price]).to eq nil
          expect(new_array.last[:prices][:xxxxxxl_price]).to eq nil
          expect(new_array.first[:prices][:xxxxxl_price]).to eq nil
          expect(new_array.last[:prices][:xxxxxl_price]).to eq nil

          expect(new_array.first[:prices][:xxxxl_price]).to_not eq nil
          expect(new_array.last[:prices][:xxxxl_price]).to_not eq nil

          new_array = new_groups[:group_2]

          expect(new_array.first[:prices][:xxxxxxl_price]).to eq nil
          expect(new_array.last[:prices][:xxxxxxl_price]).to eq nil
          expect(new_array.first[:prices][:xxxxxl_price]).to eq nil
          expect(new_array.last[:prices][:xxxxxl_price]).to eq nil

          expect(new_array.first[:prices][:xxxxl_price]).to_not eq nil
          expect(new_array.last[:prices][:xxxxl_price]).to_not eq nil
        end
      end
    end

    describe '#pricing_table_headers_for', pending: 'NO MORE PRICING TABLE' do
      it 'returns a th for each size included in the groups' do
        new_groups = omit_unused_prices_from pricing_groups
        headers = pricing_table_headers_for new_groups

        expect(headers).to have_css 'th', text: 'Item'
        expect(headers).to have_css 'th', text: 'Quantity'
        expect(headers).to have_css 'th', text: 'Sizes'
        expect(headers).to have_css 'th', text: 'Base'
        expect(headers).to have_css 'th', text: '2XL'
        expect(headers).to have_css 'th', text: '3XL'
        expect(headers).to have_css 'th', text: '4XL'
        expect(headers).to_not have_css 'th', text: '5XL'
        expect(headers).to_not have_css 'th', text: '6XL'
      end
    end
  end
end

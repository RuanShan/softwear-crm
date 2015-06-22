require 'spec_helper'

describe Search::NumberFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::NumberFilterType }

  it { is_expected.to have_db_column :field }
  it { is_expected.to have_db_column :comparator }
  it { is_expected.to validate_inclusion_of(:comparator)
                      .in_array ['>', '<', '='] }
  it { is_expected.to have_db_column :negate }
  it { is_expected.to have_db_column :value }

  let(:query) { build_stubbed :query }
  let(:order_model) { build_stubbed :search_order_model, query_id: query.id }

  let!(:filter) { build_stubbed :filter_type_number,
    value: 10,
    comparator: '>',
    field: 'commission_amount' }

  it 'belongs to search types double float and integer' do
    expect(Search::NumberFilter.search_types).to include :double
    expect(Search::NumberFilter.search_types).to include :float
    expect(Search::NumberFilter.search_types).to include :integer
  end

  describe '#apply' do
    it 'performs a search based on comparator' do
      filter.comparator = '='
      Order.search do
        filter.apply(self)
      end

      expect(Sunspot.session).to have_search_params(:with, filter.field, filter.value)
    end
  end

  it 'defaults the comparator to "="' do
    filter = Search::NumberFilter.new
    expect(filter.comparator).to eq '='
  end
end

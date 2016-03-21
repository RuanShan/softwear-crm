require 'spec_helper'

describe Search::SortFilter, search_spec: true do
  specify { expect(subject.class.ancestors).to include Search::FilterType }

  it { is_expected.to have_db_column :field }
  it { is_expected.to have_db_column :value }

  let(:query) { build_stubbed :query }
  let(:order_model) { build_stubbed :search_order_model, query_id: query.id }

  let!(:filter) { build_stubbed :filter_type_sort,
    value: 'asc',
    field: 'commission_amount' }

  it 'belongs to search types double float and integer' do
    expect(Search::NumberFilter.search_types).to include :double
    expect(Search::NumberFilter.search_types).to include :float
    expect(Search::NumberFilter.search_types).to include :integer
  end

  describe '#apply' do
    it 'calls "order_by" on the search base scope' do
      Order.search do
        filter.apply(self, self)
      end

      expect(Sunspot.session).to have_search_params(:order_by, filter.field, filter.value)
    end
  end
end

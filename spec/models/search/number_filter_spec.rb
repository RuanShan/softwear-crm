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
  end

  it 'defaults the comparator to "="' do
    filter = Search::NumberFilter.new
    expect(filter.comparator).to eq '='
  end

#  context 'searching', solr: true, pending: "solr" do
#    let!(:order1) { create :order_with_job, commission_amount: 10 }
#    let!(:order2) { create :order_with_job, commission_amount: 5 }
#    let!(:order3) { create :order_with_job, commission_amount: 1 }
#
#    it 'retrieves the correct records', pending: "solr" do
#      filter.value = 10
#      filter.comparator = '<'
#      results = assure_solr_search do
#        Order.search do
#          filter.apply(self)
#        end.results
#      end
#
#      expect(results).to_not include order1
#      expect(results).to include order2
#      expect(results).to include order3
#    end
#  end
end

require 'spec_helper'

describe Search::DateFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { should have_db_column :field }
  it { should have_db_column :comparator }
  it { should ensure_inclusion_of(:comparator).in_array ['>', '<', '='] }
  it { should have_db_column :negate }
  it { should have_db_column :value }

  let(:query) { create :query }
  let(:order_model) { create :search_order_model, query_id: query.id }

  let(:date) { 5.days.ago }

  let!(:filter) { create :filter_type_date,
    value: date,
    comparator: '>',
    field: 'in_hand_by' }

  it 'should belong to search type date' do
    expect(Search::DateFilter.search_types).to eq [:date]
  end

  it 'should apply properly with negate set to false' do
    filter.negate = false
    filter.comparator = '='
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:with, :in_hand_by, date)
  end

  it 'should apply properly with negate set to true' do
    filter.negate = true
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:without) {
      without(:in_hand_by).greater_than(date)
    }
  end
end
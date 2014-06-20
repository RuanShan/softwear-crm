require 'spec_helper'

describe Search::NumberFilter, search_spec: true do
  it { should be kind_of Search::FilterType }
  it { should have_db_column :field }

  it { should have_db_column :relation }
  it { should ensure_inclusion_of(:relation).in_array ['>', '<', '='] }

  it { should have_db_column :not }

  it { should have_db_column :value }

  let(:query) { create :query }
  let(:order_model) { create :search_order_model, query_id: query.id }

  it 'should apply properly' do
    subject.value = 10
    subject.relation = '>'
    subject.field = 'commission_amount'
    subject.save

    search = Order.search do
      subject.apply(self)
    end
    expect(search).to have_search_params(:with, :commission_amount).greater_than(10)
  end

  it 'should proxy methods to the filter' do
    expect(subject.filter_holder_id).to eq subject.filter.filter_holder_id
  end
end
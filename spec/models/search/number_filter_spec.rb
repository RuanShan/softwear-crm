require 'spec_helper'

describe Search::NumberFilter, search_spec: true do
  it { should be kind_of Search::FilterType }

  it { should have_db_column :relation }
  it { should ensure_inclusion_of(:relation).in_array ['>', '<', '='] }

  it { should have_db_column :value }

  it 'should apply properly'

  it 'should proxy methods to the filter' do
    expect(subject.filter_holder_id).to eq subject.filter.filter_holder_id
  end
end
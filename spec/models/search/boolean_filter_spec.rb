require 'spec_helper'

describe Search::BooleanFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { should have_db_column :field }
  it { should have_db_column :value }
  it { should have_db_column :negate }

  let!(:filter) { create :filter_type_boolean, field: 'is_imprintable' }

  it 'should belong to search type boolean' do
    expect(Search::BooleanFilter.search_types).to eq [:boolean]
  end

  it 'should apply properly when not negated' do
    filter.negate = false
    filter.value = true
    filter.save

    LineItem.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:with, filter.field, true)
  end
  it 'should apply properly when negated' do
    filter.negate = true
    filter.value = true
    filter.save

    LineItem.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:without, filter.field, true)
  end
end
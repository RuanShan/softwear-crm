require 'spec_helper'

describe Search::StringFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { is_expected.to have_db_column :field }
  it { is_expected.to have_db_column :value }
  it { is_expected.to have_db_column :negate }

  let!(:filter) { create :filter_type_string, 
    field: 'terms', value: 'Paid in full on pick up' }

  it 'belongs to search type string' do
    expect(Search::StringFilter.search_types).to eq [:string]
  end

  it 'applies properly when not negated' do
    filter.negate = false
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:with, 'terms', 'Paid in full on pick up')
  end
  it 'applies properly when negated' do
    filter.negate = true
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:without, 'terms', 'Paid in full on pick up')
  end
end
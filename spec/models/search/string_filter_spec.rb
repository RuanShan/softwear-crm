require 'spec_helper'

describe Search::StringFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { should have_db_column :field }
  it { should have_db_column :value }
  it { should have_db_column :negate }

  let!(:filter) { create :filter_type_string, 
    field: 'sales_status', value: 'Pending' }

  it 'should apply properly when not negated' do
    filter.negate = false
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:with, 'sales_status', 'Pending')
  end
  it 'should apply properly when negated' do
    filter.negate = true
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:without, 'sales_status', 'Pending')
  end
end
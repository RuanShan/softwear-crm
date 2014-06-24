require 'spec_helper'

describe Search::ReferenceFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { should have_db_column :field }
  it { should have_db_column :negate }
  it { should belong_to :value }

  let(:user) { create :user }
  let!(:filter) { create :filter_type_reference, 
    field: 'salesperson', value: user }

  it 'should apply properly when not negated' do
    filter.negate = false
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:with, 'salesperson', user)
  end
  it 'should apply properly when negated' do
    filter.negate = true
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:without, 'salesperson', user)
  end
end
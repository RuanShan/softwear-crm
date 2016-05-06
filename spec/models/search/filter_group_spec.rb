require 'spec_helper'

describe Search::FilterGroup, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { is_expected.to have_many(:filters).dependent(:destroy) }
  it { is_expected.to have_db_column :all }

  let!(:group) { build_stubbed :filter_type_group }

  let!(:order1) { build_stubbed :deprecated_order_with_job,
    name: 'keywordone keywordtwo',
    deprecated_firstname: 'keywordtwo',
    commission_amount: 50.25 }
  let!(:order2) { build_stubbed :deprecated_order_with_job,
    name: 'keywordtwo keywordthree',
    deprecated_firstname: 'keywordone',
    commission_amount: 30.15 }
  let!(:order3) { build_stubbed :deprecated_order_with_job,
    name: 'keywordfour',
    deprecated_firstname: 'keywordfour',
    commission_amount: 10.30 }

  context 'when the group has filters in it' do
    before(:each) do
      filters = []

      filters << build_stubbed(:number_filter,
        field: 'commission_amount',
        value: 30, comparator: '<')

      filters << build_stubbed(:string_filter,
        field: 'firstname', negate: true)

      allow(group).to receive(:filters).and_return filters
    end

    it 'applies all contained filters' do
      # Must be local variable; search blocks are called in 
      # a different context.
      group_type = group
      Order.search do
        group_type.apply(self, self)
      end
      group.filters.each do |filter|
        expect(Sunspot.session).to have_search_params(filter.with_func) {
          filter.apply(self, self)
        }
      end
    end

    describe '#of_func' do
      it 'evaluated to all_of or any_of based on the "all" attribute' do
        group.all = true
        expect(group.of_func).to eq :all_of
        group.all = false
        expect(group.of_func).to eq :any_of
      end
    end
  end

end
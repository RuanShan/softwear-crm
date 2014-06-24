require 'spec_helper'

describe Search::FilterGroup, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { should have_many :filters }
  it { should have_db_column :all }

  let!(:group) { create :filter_type_group }

  let!(:order1) { create :order_with_job,
    name: 'keywordone keywordtwo',
    firstname: 'keywordtwo',
    commission_amount: 50.25 }
  let!(:order2) { create :order_with_job,
    name: 'keywordtwo keywordthree',
    firstname: 'keywordone',
    commission_amount: 30.15 }
  let!(:order3) { create :order_with_job,
    name: 'keywordfour',
    firstname: 'keywordfour',
    commission_amount: 10.30 }

  context 'when the group has filters in it' do
    before(:each) do
      group.filters << create(:number_filter,
        field: 'commission_amount',
        value: 30, relation: '<')

      group.filters << create(:string_filter,
        field: 'firstname', negate: true)
    end

    it 'should apply all contained filters' do
      # Must be local variable; search blocks are called in 
      # a different context.
      group_type = group
      Order.search do
        group_type.apply(self)
      end
      group.filters.each do |filter|
        expect(Sunspot.session).to have_search_params(filter.with_func) {
          filter.apply(self)
        }
      end
    end

    it 'applies them inside the correct function' do
      group.all = true; group.save
      expect(group.of_func).to eq :all_of
      group.all = false; group.save
      expect(group.of_func).to eq :any_of
    end
  end

end
require 'spec_helper'

describe Search::StringFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { is_expected.to have_db_column :field }
  it { is_expected.to have_db_column :value }
  it { is_expected.to have_db_column :negate }

  let!(:filter) { build_stubbed :filter_type_string, 
    field: 'terms', value: 'Paid in full on pick up' }

  it 'belongs to search type string' do
    expect(Search::StringFilter.search_types).to eq [:string]
  end

  describe '#apply' do
    context 'when negated' do
      before { filter.negate = true }

      it 'adds a sunspot :without filter on its field' do
        Order.search do
          filter.apply(self)
        end
        expect(Sunspot.session)
          .to have_search_params(:without, 'terms', 'Paid in full on pick up')
      end
    end

    context 'when not negated' do
      before { filter.negate = false }

      it 'adds a sunspot :with filter on its field' do
        Order.search do
          filter.apply(self)
        end
        expect(Sunspot.session)
          .to have_search_params(:with, 'terms', 'Paid in full on pick up')
      end
    end
  end
end
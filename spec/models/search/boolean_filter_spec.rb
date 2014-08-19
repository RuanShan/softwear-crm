require 'spec_helper'

describe Search::BooleanFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { is_expected.to have_db_column :field }
  it { is_expected.to have_db_column :value }
  it { is_expected.to have_db_column :negate }

  let!(:filter) { create :filter_type_boolean, field: 'is_imprintable' }

  it 'belongs to search type boolean' do
    expect(Search::BooleanFilter.search_types).to eq [:boolean]
  end

  describe '#apply' do
    context 'when not negated' do
      before { filter.negate = false }

      it 'applies a sunspot :without filter on its field' do
        filter.value = true

        LineItem.search do
          filter.apply(self)
        end
        expect(Sunspot.session)
          .to have_search_params(:with, filter.field, true)
      end
    end

    context 'when negated' do
      before { filter.negate = true }

      it 'applies a sunspot :with filter on its field' do
        filter.value = true

        LineItem.search do
          filter.apply(self)
        end
        expect(Sunspot.session)
          .to have_search_params(:without, filter.field, true)
      end
    end
  end
end
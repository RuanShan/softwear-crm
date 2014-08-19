require 'spec_helper'

describe Search::ReferenceFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { is_expected.to have_db_column :field }
  it { is_expected.to have_db_column :negate }
  it { is_expected.to belong_to :value }

  let(:user) { create :user }
  let!(:filter) { create :filter_type_reference, 
    field: 'salesperson', value: user }

  it 'belongs to search type reference' do
    expect(Search::ReferenceFilter.search_types).to eq [:reference]
  end

  describe '#apply' do
    context 'when negated' do
      before { filter.negate = true }

      it 'applies a sunspot :without filter on its field' do
        Order.search do
          filter.apply(self)
        end
        expect(Sunspot.session)
          .to have_search_params(:without, 'salesperson', user)
      end
    end

    context 'when not negated' do
      before { filter.negate = false }

      it 'applies a sunspot :with filter on its field' do
        Order.search do
          filter.apply(self)
        end
        expect(Sunspot.session)
          .to have_search_params(:with, 'salesperson', user)
      end
    end
  end

  describe '.assure_value' do
    it 'returns an actual record based off <model name>#<id>' do
      expect(Search::ReferenceFilter.assure_value("User##{user.id}")).to eq user
    end
  end
end
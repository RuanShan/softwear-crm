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

  it 'applies properly when not negated' do
    filter.negate = false
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:with, 'salesperson', user)
  end
  it 'applies apply properly when negated' do
    filter.negate = true
    filter.save

    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to have_search_params(:without, 'salesperson', user)
  end

  describe '.assure_value' do
    it 'returns an actual record based off <model name>#<id>' do
      expect(Search::ReferenceFilter.assure_value("User##{user.id}")).to eq user
    end
  end
end
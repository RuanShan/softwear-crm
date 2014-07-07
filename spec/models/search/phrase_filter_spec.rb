require 'spec_helper'

describe Search::PhraseFilter, search_spec: true do
  let!(:filter) { create :filter_type_phrase, 
    field: 'sales_status', value: '"Pending"' }

  it 'should belong to search type text' do
    expect(Search::PhraseFilter.search_types).to eq [:text]
  end

  it 'should not use the with/without syntax' do
    Order.search do
      filter.apply(self)
    end
    expect(Sunspot.session).to_not have_search_params(:with, :sales_status, '"Pending"')
  end
end
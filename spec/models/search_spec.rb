require 'spec_helper'

describe 'Search', search_spec: true do
  # TODO THURSDAY do consider actually eager loading models
  # 
  # ALSO I don't think fulltext is needed wtf? It would be 
  # a text_filter... This is turning out insanely simpler
  # than I thought :(

  describe '.Models' do
    describe '.all' do
      it 'should return all searchable model types' do
        expect(Search::Models.all).to include Order
      end
    end
  end
  it 'All models should have the searchable_fields method' do
    expect(Order.searchable_fields).to include 'name'
  end
end

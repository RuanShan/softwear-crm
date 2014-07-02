require 'spec_helper'

describe 'Search', search_spec: true do
  describe '::Models' do
    describe '.all' do
      it 'should return all searchable model types' do
        expect(Search::Models.all).to include Order
      end
    end
  end

  it 'All models should have the searchable_fields method' do
    expect(Order.searchable_fields.values).to include Search::Field['Order', 'name']
  end
end

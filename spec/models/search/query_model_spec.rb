require 'spec_helper'

describe Search::QueryModel, search_spec: true do
  it { should belong_to :query }
  it { should have_db_column :name }
  it { should have_many :query_fields }
  it { should have_one :filter, as: :filter_holder }

  it 'should be destroyed when its parent query is destroyed' do
    query = create(:search_query)
    create(:search_order_model, query_id: query.id)
    expect(Search::QueryModel.where(name: 'Order')).to exist

    query.destroy

    expect(Search::QueryModel.where(name: 'Order')).to_not exist
  end

  describe '#fields' do
    let!(:model) { create(:search_order_model) }
    context 'when there are no query_fields' do
      it 'returns an array of all fields in the model' do
        expect(model.fields).to eq Order.searchable_fields
      end
    end

    context 'when there are query fields' do
      it 'returns the Search::Fields that the query fields represent' do
        model.add_field 'name'
        model.add_field 'email'
        expect(model.fields).to eq [Search::Field[:Order, :name], Search::Field[:Order, :email]]
      end
    end
  end

  describe '#add_field' do
    let!(:model) { create(:search_order_model) }
    it 'should add a field with the given name if it is fulltext searchable' do
      model.add_field 'email'
      expect(model.fields).to eq [Search::Field[:Order, :email]]
    end
    it 'should raise an error if the field with the given name is not text' do
      expect{model.add_field 'commission_amount'}.to raise_error
    end
  end
end
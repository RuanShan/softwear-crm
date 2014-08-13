require 'spec_helper'
include GeneralHelpers

describe Search::QueryModel, search_spec: true do
  it { is_expected.to belong_to :query }
  it { is_expected.to have_db_column :name }
  it { is_expected.to have_many :query_fields }
  it { is_expected.to have_db_column :default_fulltext }
  it { is_expected.to have_one :filter }

  let!(:model) { create(:query_order_model) }

  it 'validates that the represented model is searchable' do
    expect(Search::QueryModel.new(name: 'Order')).to be_valid
    expect(Search::QueryModel.new(name: 'Search::Query')).to_not be_valid
  end

  it 'destroys its filter when destroyed' do
    model.filter = create(:number_filter)
    expect(Search::Filter.count).to eq 1
    expect(Search::NumberFilter.count).to eq 1

    model.destroy

    expect(Search::Filter.count).to eq 0
    expect(Search::NumberFilter.count).to eq 0
  end

  describe '#fields' do
    context 'when there are no query_fields' do
      it 'returns an array of all fields in the model' do
        expect(model.fields).to eq Order.searchable_fields
      end
    end

    context 'when there are query fields' do
      it 'returns the Search::Fields that the query fields represent' do
        create(:query_order_name_field, query_model_id: model.id)
        create(:query_order_email_field, query_model_id: model.id)
        expect(model.fields).to eq [Search::Field[:Order, :name], Search::Field[:Order, :email]]
      end
    end
  end

  describe '#add_field' do
    let!(:model) { create(:query_order_model) }
    
    it 'adds a field with the given name if it is fulltext searchable' do
      model.add_field 'email'
      expect(model.fields).to eq [Search::Field[:Order, :email]]
    end
    it 'raises an error if the field with the given name is not text' do
      expect(model).to respond_to :add_field
      expect{model.add_field 'commission_amount'}.to raise_error
    end
  end
end
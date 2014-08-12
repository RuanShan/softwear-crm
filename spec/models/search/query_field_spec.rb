require 'spec_helper'
include GeneralHelpers

describe Search::QueryField, search_spec: true do
  it { is_expected.to belong_to :query_model }
  # it { is_expected.to have_one :query, through: :query_model }
  it { is_expected.to have_db_column :name }
  it { is_expected.to have_db_column :boost }
  it { is_expected.to have_db_column :phrase }

  let!(:order) { create :order_with_job }
  let!(:field) { create :query_order_name_field }

  it 'defaults boost to 1' do
    expect(Search::QueryField.new.boost).to eq 1
  end

  describe '#to_h' do
    context 'when boost is null' do
      it 'returns name => 1' do
        expect(field.to_h).to eq('name' => 1)
      end
    end
    context 'when boost is something else' do
      it 'returns name => boost' do
        field.boost = 2
        field.save
        expect(field.to_h).to eq('name' => 2)
      end
    end
  end
end

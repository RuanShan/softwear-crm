require 'spec_helper'

describe Search::Field, search_spec: true do
  it { should have_db_column :name }
  it { should have_db_column :type }

  describe '.ensure_for(model, field, type)', ensure_for: true do
    let!(:subject) { -> { Search::Field.ensure_for Order, :name, :string } }

    it 'creates the appropriate model and field records' do
      expect(Search::Model.where(name: 'Order')).to_not exist
      expect(Search::Field.where(name: 'name', type: 'string')).to_not exist

      subject.call()

      expect(Search::Model.where(name: 'Order')).to exist
      expect(Search::Field.where(name: 'name', type: 'string', 
        model_id: Search::Model.where(name: 'Order').first.id)).to exist
    end
    context 'when the model exists' do
      let!(:order_model) { Search::Model.create!(name: 'Order') }

      it 'creates the field record under the exising model' do
        expect(Search::Field.where(name: 'name', type: 'string')).to_not exist

        subject.call()

        expect(Search::Model.where(name: 'Order')).to exist
        expect(Search::Field.where(name: 'name', type: 'string', model_id: order_model.id)).to exist
      end

      context 'and the field exists' do
        let!(:order_name_field) { Search::Field.create!(name: 'name', type: 'text', 
          model_id: order_model.id) }

        it 'does nothing' do
          expect(queries_after(&subject)).to eq 2
        end
      end
    end
  end


  it { should belong_to :model }
  it { should have_and_belong_to :query }
end

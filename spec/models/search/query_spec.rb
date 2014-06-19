require 'spec_helper'

describe Search::Query, search_spec: true do
  it { should belong_to :user }
  it { should have_db_column :name }

  it { should have_many :models, class_name: 'Search::QueryModel' }
  # it { should have_many :fields, class_name: 'Search::QueryField', through: :models }

  describe '#search' do
    context 'when the query has no models' do
      it 'searches all models and fields' do
        subject.search 'test'
        expect(Sunspot.session.searches.count).to eq Search::Models.count
      end
    end

    context 'with models' do
      let!(:order_model) { create :search_order_model, query_id: subject.id }
      let(:job_model) { create :search_job_model, query_id: subject.id }

      it 'searches the models' do
        job_model; subject.search 'test'
        expect(Sunspot.session.searches.first).to be_a_search_for Order
        expect(Sunspot.session.searches.last).to be_a_search_for Job
      end

      context 'and a field' do
        before(:each) do
          order_model.add_field 'name'
        end

        it 'just searches that field' do
          subject.search 'test'
          expect(Sunspot.session.searches.first).to have_search_params(:fulltext, 'test') {
            expect(Sunspot.session.searches.first).to have_search_params :fields, :name
          }
        end
      end

      context 'with filters' do
        let!(:commission_amount_filter) {
          create(:number_filter, value: 2.20, relation: '<')
        }
        before(:each) do
          number_filter.filter.filter_holder = order_model
          number_filter.filter.save
        end

        it 'applies the filter' do
          expect(number_filter).to receive(:apply)
          subject.search 'test'
        end
      end
    end
  end
end
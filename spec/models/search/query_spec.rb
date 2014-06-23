require 'spec_helper'
include GeneralHelpers

describe Search::Query, search_spec: true do
  it { should belong_to :user }
  it { should have_db_column :name }

  it { should have_many :query_models }
  # it { should have_many :fields, class_name: 'Search::QueryField', through: :models }

  describe '#models' do
    context 'when the query has no models' do
      it 'returns all searchable models' do
        expect(subject.models).to eq Search::Models.all
      end
    end

    context 'with models' do
      let!(:order_model) { create :query_order_model, query: subject }
      let!(:job_model) { create :query_job_model, query: subject }

      it 'only returns its models' do
        expect(subject.models).to eq [Order, Job]
      end
    end
  end

  describe '#search' do
    context 'when the query has no models' do
      it 'searches all models and fields' do
        expect(subject.search('test').count).to eq Search::Models.count
      end
    end

    context 'with models' do
      let!(:order1) { create :order_with_job, 
        name: 'keywordone keywordtwo', 
        firstname: 'keywordtwo' }
      let!(:order2) { create :order_with_job, 
        name: 'keywordtwo keywordthree', 
        firstname: 'keywordone' }
      let!(:order3) { create :order_with_job, 
        name: 'keywordfour', 
        firstname: 'keywordfour' }
      let!(:order_model) { create :query_order_model, query: subject }
      let(:job_model) { create :query_job_model, query: subject }

      it 'searches the models' do
        job_model; subject.search 'test'
        with(Sunspot.session.searches) do |the|
          expect(the.count).to eq 2
          expect(the.first).to be_a_search_for Order
          expect(the.last).to be_a_search_for Job
        end
      end

      it 'uses the right fulltext' do
        subject.search 'test'
        expect(Sunspot.session).to have_search_params :fulltext, 'test'
      end

      context 'and a field' do
        before(:each) do
          order_model.add_field 'name'
        end

        it 'just searches that field', solr: true do
          search = subject.search 'keywordone'
          expect(search.count).to eq 1
          expect(search.first.results.count).to eq 1
          expect(search.first.results).to include order1
          expect(search.first.results).to_not include order2
        end
      end

      context 'with filters' do
        let!(:commission_amount_filter) {
          create(:number_filter, value: 2.20, relation: '<',
            field: 'commission_amount')
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
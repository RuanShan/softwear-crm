require 'spec_helper'
include GeneralHelpers

describe Search::Query, search_spec: true do
  it { should belong_to :user }
  it { should have_db_column :name }
  it { should validate_uniqueness_of(:name).scoped_to :user_id }
  it { should have_db_column :default_fulltext }

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

    describe '.combine' do
      let!(:order1) { create :order_with_job, 
        name: 'keyone', 
        firstname: 'keyone' }
      let!(:order2) { create :order_with_job, 
        name: 'keyone', 
        firstname: 'keyone',
        company: 'keyone and friends' }
      let!(:order3) { create :order_with_job, 
        name: 'keytwo', 
        firstname: 'keyone' }

      it 'combines all of the search results', :solr do
        create(:job, name: 'keyone job')
        expect(subject.search('keyone').combine.count).to eq 4
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

        it 'just searches that field', :s1, solr: true do
          search = subject.search 'keywordone'
          expect(search.count).to eq 1
          expect(search.first.results.count).to eq 1
          expect(search.first.results).to include order1
          expect(search.first.results).to_not include order2
        end

        context 'and filters' do
          let!(:filter) { create :string_filter, 
            filter_type: create(:filter_type_string,
              field: 'firstname', value: 'keywordfour') }
          before(:each) do
            filter.filter_holder = order_model
            filter.save
          end

          it 'cleans up after itself' do
            job_model
            subject.destroy
            expect(Search::Query.count).to eq 0
            expect(Search::QueryModel.count).to eq 0
            expect(Search::QueryField.count).to eq 0
            expect(Search::Filter.count).to eq 0
          end
        end
      end

      context 'and filters' do
        let!(:filter) { create :string_filter, 
          filter_type: create(:filter_type_string,
            field: 'firstname', value: 'keywordfour') }
        before(:each) do
          filter.filter_holder = order_model
          filter.save
        end

        it 'applies the filter', :s2, solr: true do
          results = subject.search.first.results
          expect(results).to include order3
          expect(results).to_not include order1
          expect(results).to_not include order2
        end
      end
    end
  end
end
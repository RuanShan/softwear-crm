require 'spec_helper'

describe Search::Query, search_spec: true do
  it { is_expected.to belong_to :user }
  it { is_expected.to have_db_column :name }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to :user_id }
  it { is_expected.to_not have_db_column :default_fulltext }

  it { is_expected.to have_many :query_models }

  it 'does not allow an empty name if user_id is not nil' do
    subject.user_id = 1
    subject.name = ""
    expect(subject).to_not be_valid
  end

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

   # describe '.combine', combine: true do
   #   let!(:order1) { create :order_with_job, 
   #     name: 'keyone', 
   #     firstname: 'keyone' }
   #   let!(:order2) { create :order_with_job, 
   #     name: 'keyone', 
   #     firstname: 'keyone',
   #     company: 'keyone and friends' }
   #   let!(:order3) { create :order_with_job, 
   #     name: 'keytwo', 
   #     firstname: 'keyone' }

   #   it 'combines all of the search results', solr: true do
   #     create(:job, name: 'keyone job')
   #     assure_solr_search(expect: 4) do
   #       subject.search('keyone').combine
   #     end
   #   end
   # end

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
        expect(Sunspot.session.searches.count).to eq 2
        expect(Sunspot.session.searches.first).to be_a_search_for Order
        expect(Sunspot.session.searches.last).to be_a_search_for Job
      end

      it 'uses the right fulltext when passed a string parameter' do
        subject.search 'test'
        expect(Sunspot.session).to have_search_params :fulltext, 'test'
      end

      it 'uses the default fulltext when not passed a string parameter' do
        order_model.default_fulltext = 'lets go'
        order_model.save
        subject.search
        expect(Sunspot.session).to have_search_params :fulltext, 'lets go'
      end

      context 'and a field' do
        before(:each) do
          order_model.add_field 'name'
        end

     #   it 'just searches that field', solr: true, retry: 5 do
     #     search = assure_solr_search do
     #       subject.search 'keywordone'
     #     end
     #     expect(search.count).to eq 1
     #     expect(search.first.results.count).to eq 1
     #     expect(search.first.results).to include order1
     #     expect(search.first.results).to_not include order2
     #   end

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

     #   it 'applies the filter', solr: true do
     #     results = assure_solr_search do
     #       subject.search.first.results
     #     end
     #     expect(results).to include order3
     #     expect(results).to_not include order1
     #     expect(results).to_not include order2
     #   end

        describe '#filter_for' do
          it 'returns the filter associated with the given field' do
            expect(subject.filter_for(Search::Field[:Order, :firstname])).to eq filter
          end

          it 'returns the filter associated with the given model and field name' do
            expect(subject.filter_for(Order, :firstname)).to eq filter
          end

          it 'returns nil if it could not find a filter' do
            expect(subject.filter_for(Order, :company)).to be_nil
          end

          context 'when the filter is buried' do
            let!(:group1) { create(:filter_group) }
            let!(:group2) { create(:filter_group, filter_holder: group1.type) }
            let!(:useless_filter) { create(:number_filter, filter_holder: group2.type) }

            before(:each) do
              filter.filter_holder = group2.type
              filter.save
              group1.filter_holder = order_model
              group1.save
            end

            it 'can find it from within the groups' do
              expect(subject.filter_for(Order, :firstname)).to eq filter
            end
          end
        end
      end
    end
  end
end

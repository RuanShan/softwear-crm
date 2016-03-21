require 'spec_helper'

describe Search::QueriesController, search_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  let(:test_params) do
    {search: {
        order: {
            '1' => { lastname: 'Johnson' },
            '2' => { commission_amount: 200 },
            fulltext: 'test'
        }}}
  end

  let(:test_params_with_locals) do
    test_params.merge(
        locals: {test_val: 'hello'}
    )
  end

  let!(:test_params_with_boolean) do
    {search: {
        imprintable: {
            '1' => { standard_offering: 'false' },
            fulltext: 'yeah'
        }}}
  end

  let!(:test_params_with_reference) do
    {search: {
        order: {
            '1' => { salesperson: "User##{valid_user.id}" },
            fulltext: 'yeah'
        }}}
  end

  let!(:test_params_with_phrase_filter) do
    {search: {
        order: {
            '1' => { jobs: 'Whoa! This would also include a description.' },
            fulltext: 'yeah'
        }}}
  end

  let(:test_params_with_nil) do
    {search: {
        order: {
            '1' => { lastname: 'nil' },
            fulltext: 'test'
        }}}
  end

  let(:test_params_with_model_level_fulltext) do
    {search: {
        fulltext: 'test',
        order: {
            '1' => { lastname: 'Johnson' },
            '2' => { commission_amount: 200 },
        },
        job: {
            '1' => { name: 'whocares' }
        }
    }}
  end

  let(:test_params_with_metadata) do
    {search: {
        order: {
            '1' => { firstname: 'Nigel', _metadata: ['negate'] },
            '2' => { lastname: 'Baillie' },
            '3' => { commission_amount: 15.00,
                     _metadata: ['negate', 'greater_than'] },
            fulltext: 'ftestasdlfkj'
        }}}
  end

  let(:test_params_with_lessthan_metadata) do
    {search: {
        order: {
            '1' => { lastname: 'Baillie' },
            '2' => { commission_amount: 15.00,
                     _metadata: ['less_than'] },
            fulltext: 'ftestasdlfkj'
        }}}
  end

  let(:test_params_with_group) do
    {search: {
        order: {
            '1' => { company: 'Some Stuff' },
            '2' => { _group: {
                '1' => { lastname: 'Whatever' },
                '2' => { lastname: 'Whatnot' },
            }, _metadata: ['any_of'] },
            fulltext: 'cool stuff'
        }}}
  end

  let(:test_params_with_order_by) do
    {search: {
        fulltext: 'test',
        order: {
            '1' => { lastname: 'Johnson' },
            order_by: ['commission_amount', 'asc']
        }}
    }
  end

  let(:query) { create(:search_query) }
  let(:order_model) do
    create(:query_order_model, query: query, default_fulltext: 'success')
  end
  let(:job_model) do
    create(:query_job_model, query: query, default_fulltext: 'testing')
  end

  context 'GET' do
    describe '#search' do
      context 'when params contains a query id' do
        before(:each) do
          order_model.filter = create(:filter_group)
          order_model.filter.filters << create(:string_filter)
          query.save
        end

        it 'searches with that query' do
          get :search, id: query.id
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          expect(Sunspot.session).to be_a_search_for Order
          expect(Sunspot.session).to have_search_params(:fulltext, 'success')
          expect(Sunspot.session)
            .to have_search_params(:with, :firstname, 'Test')
        end
      end

      it 'should ignore fields filtered on the string value "nil"' do
        get :search, test_params_with_nil
        expect(response).to be_ok

        expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

        expect(Sunspot.session).to be_a_search_for Order
        expect(Sunspot.session).to have_search_params(:fulltext, 'test')
        expect(Sunspot.session)
          .to_not have_search_params(:with, :lastname, 'nil')
      end

      context 'when params contains search info' do
        it 'searches with the given filter info' do
          get :search, test_params
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          expect(Sunspot.session).to be_a_search_for Order
          expect(Sunspot.session).to have_search_params(:fulltext, 'test')
          expect(Sunspot.session)
            .to have_search_params(:with, :lastname, 'Johnson')
          expect(Sunspot.session)
            .to have_search_params(:with, :commission_amount, 200)
        end

        it 'should apply fulltext if defined on the model-level' do
          get :search, test_params_with_model_level_fulltext
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          searches = Sunspot.session.searches

          expect(searches.first).to be_a_search_for Order
          expect(searches.second).to be_a_search_for Job

          expect(searches.first).to have_search_params(:fulltext, 'test')
          expect(searches.last).to have_search_params(:fulltext, 'test')
        end

        it 'applies booleans properly' do
          get :search, test_params_with_boolean
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          expect(Sunspot.session).to be_a_search_for Imprintable
          expect(Sunspot.session)
            .to have_search_params(:with, :standard_offering, false)
        end

        it 'applies references properly' do
          get :search, test_params_with_reference
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          expect(Sunspot.session).to be_a_search_for Order
          expect(Sunspot.session)
            .to have_search_params(:with, :salesperson, valid_user)
        end

        context 'and metadata', metadata: true do
          it 'applies the "negate" metadata properly' do
            get :search, test_params_with_metadata
            expect(response).to be_ok

            expect(assigns[:search].first)
              .to be_a Sunspot::Search::StandardSearch

            expect(Sunspot.session).to be_a_search_for Order
            expect(Sunspot.session)
              .to have_search_params(:fulltext, 'ftestasdlfkj')
            expect(Sunspot.session)
              .to have_search_params(:without, :firstname, 'Nigel')
          end

          it 'applies the "less_than" metadata properly' do
            get :search, test_params_with_lessthan_metadata
            expect(response).to be_ok

            expect(assigns[:search].first)
              .to be_a Sunspot::Search::StandardSearch

            expect(Sunspot.session).to be_a_search_for Order
            expect(Sunspot.session).to have_search_params(:with) {
              with(:commission_amount).less_than(15.00)
            }
          end

          it 'applies the "greater_than" AND "negate" metadata properly' do
            get :search, test_params_with_metadata
            expect(response).to be_ok

            expect(assigns[:search].first)
              .to be_a Sunspot::Search::StandardSearch

            expect(Sunspot.session).to be_a_search_for Order
            expect(Sunspot.session)
              .to have_search_params(:fulltext, 'ftestasdlfkj')
            expect(Sunspot.session).to have_search_params(:with) {
              without(:commission_amount).greater_than(15.00)
            }
          end
        end

        context 'and order_by', order_by: true do
          it 'applies order_by with the two array values of the param' do
            get :search, test_params_with_order_by
            expect(response).to be_ok

            expect(assigns[:search].first)
              .to be_a Sunspot::Search::StandardSearch

            expect(Sunspot.session).to be_a_search_for Order
            expect(Sunspot.session)
              .to have_search_params(:order_by, 'commission_amount', 'asc')
          end
        end

        context 'and a group', group: true do
          it 'applies the group properly within the search' do
            get :search, test_params_with_group
            expect(response).to be_ok

            expect(assigns[:search].first)
              .to be_a Sunspot::Search::StandardSearch

            expect(Sunspot.session).to be_a_search_for Order
            expect(Sunspot.session)
              .to have_search_params(:fulltext, 'cool stuff')
            expect(Sunspot.session)
              .to have_search_params(:with, :company, 'Some Stuff')
            expect(Sunspot.session).to have_search_params(:with) {
              any_of do
                with :lastname, 'Whatever'
                with :lastname, 'Whatnot'
              end
            }
          end
        end

        context 'passing locals', locals: true do
          it 'should allow the passing of locals, if permitted' do
            allow(OrdersController).to receive(:permitted_search_locals)
              .and_return [:test_val]

            get :search, test_params_with_locals
            expect(OrdersController).to have_received(:permitted_search_locals)
          end

          context 'with custom logic' do
            it "calls #transform_search_locals on the model's controller" do
              allow(OrdersController).to receive(:permitted_search_locals)
                .and_return [:test_val]
              allow(OrdersController).to receive(:transform_search_locals)
                .and_return(new_test_val: "transformed!")

              get :search, test_params_with_locals
              expect(OrdersController).to have_received :transform_search_locals
            end
          end
        end
      end
    end
  end

  context 'PUT' do
    describe '#update', :update do
      it 'updates the given query with the given filter info, name and user' do
        job_model.filter = create(:filter_group)
        job_model.filter.filters << create(:string_filter, field: 'name')
        query.save

        expect(Search::QueryModel.count).to eq 1

        put :update, test_params.merge(id: query.id, query: {name: 'new name'})
        expect(response.status).to eq 302

        expect(assigns[:query]).to eq query
        expect(Search::QueryModel.count).to eq 1
        expect(query.query_models.first.filter.filters.count).to eq 2
        expect(assigns[:query].name).to eq 'new name'
      end
    end
  end

  context 'POST' do
    describe '#create', :create do
      it 'creates a new query with the given filter info for the given user' do
        post :create,
             test_params.merge(query: {user_id: valid_user.id, name: 'test q'})
        expect(response).to be_ok

        expect(assigns[:query]).to be_a Search::Query
        expect(assigns[:query].query_models.first.name).to eq 'Order'
        expect(assigns[:query].query_models.first.filter.filters.first.field)
          .to eq 'lastname'
        expect(assigns[:query].name).to eq 'test q'

        expect(valid_user.search_queries).to include assigns[:query]
      end

      it 'redirects to params[:target_path] if present' do
        post :create, test_params.merge(target_path: '/')
        expect(response).to redirect_to '/'
      end
    end
  end

  context 'DELETE' do
    describe '#destroy' do
      it 'destroys the query' do
        delete :destroy, id: query.id
        expect(Search::Query.count).to eq 0
      end
    end
  end
end

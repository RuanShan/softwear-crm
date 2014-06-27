require 'spec_helper'

describe Search::QueryBuilder, search_spec: true do

  describe '#build' do
    context 'without a block' do
      it 'should be able to build a fulltext search on all models' do
        query = Search::QueryBuilder.build.query
        expect(query.models).to eq Search::Models.all
      end
    end
    context 'with a block' do
      it 'should be able to build search on just some fields in one model' do
        query = Search::QueryBuilder.build do
          on(Order) do
            fields :name, :email
          end
        end.query

        expect(query.query_models.count).to eq 1
        order_model = query.query_models.first

        expect(order_model.query_fields.count).to eq 2
        expect(order_model.fields).to include Search::Field[:Order, :name]
        expect(order_model.fields).to include Search::Field[:Order, :email]
      end

      it 'should be able to specify boost to some fields' do
        query = Search::QueryBuilder.build do
          on(Order) do
            fields :email, name: 2
          end
        end.query

        order_model = query.query_models.first
        expect(order_model.query_fields.count).to eq 2
        expect(order_model.query_fields.first.boost).to eq 1
        expect(order_model.query_fields.last.boost).to eq 2
      end

      it 'should be able to build a search on more than one model' do
        query = Search::QueryBuilder.build do
          on(Order, Job)
        end.query

        expect(query.query_models.count).to eq 2
      end

      it 'should be able to build a search with one filter' do
        query = Search::QueryBuilder.build do
          on(Order) do
            with(:commission_amount).less_than 100.50
          end
        end.query

        order_model = query.query_models.first
        expect(order_model.filter.type).to be_a Search::FilterGroup

        group = order_model.filter.type
        expect(group.filters.count).to eq 1
        expect(group.filters.first.value).to eq 100.50
        expect(group.filters.first.comparator).to eq '<'
      end

      it 'should be able to build a search with multiple filters' do
        query = Search::QueryBuilder.build do
          on(Order) do
            with(:commission_amount, 50.55)
            without(:lastname, 'Johnson')
          end
        end.query

        order_model = query.query_models.first
        expect(order_model.filter.type).to be_a Search::FilterGroup

        group = order_model.filter.type
        expect(group.all).to be_truthy
        expect(group.filters.first.type).to be_a Search::NumberFilter
        expect(group.filters.last.type).to be_a Search::StringFilter
        expect(group.filters.last.negate).to be_truthy
      end

      it 'should be able to build a search with many filters' do
        salesperson = create(:user)
        query = Search::QueryBuilder.build do
          on(Order) do
            any_of do
              with(:lastname, 'Johnson')
              with(:salesperson, salesperson)
              all_of do
                without(:in_hand_by).less_than Time.now
                with(:commission_amount, 55.50)
              end
            end
          end
        end.query

        order_model = query.query_models.first
        expect(order_model.filter.type).to be_a Search::FilterGroup
        expect(order_model.filter.all).to be_truthy

        group = order_model.filter.type
        expect(group.filters.count).to eq 1
        expect(group.filters.last.type).to be_a Search::FilterGroup

        inner_group = group.filters.last.type
        expect(inner_group.all).to_not be_truthy
        expect(inner_group.filters.count).to eq 3

        inner_inner_group = inner_group.filters.last.type
        expect(inner_inner_group.all).to be_truthy
        expect(inner_inner_group.filters.count).to eq 2
      end
    end
  end
end
require 'spec_helper'
include LineItemHelpers

describe LineItemsController, line_item_spec: true do
  render_views
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe '#create', create: true do
    context 'with an imprintable_id and a color_id' do
      let!(:job) { create(:job) }
      let(:order) { job.order }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }
      let(:activities) { PublicActivity::Activity.where(trackable_type: 'LineItem') }

      make_variants :white, :shirt, [:S, :M, :L, :XL], not: [:job, :line_items]

      it 'creates line items for each relevant size' do
        post :create, format: :json, 
                      job_id:         job.id,
                      imprintable_id: shirt.id,
                      color_id:       white.id
        json_response = JSON.parse response.body
        expect(json_response['result']).to eq 'success'
        expect(
          LineItem.where(imprintable_object_id: white_shirt_s.id,
                         imprintable_object_type: 'ImprintableVariant')
        ).to exist
        expect(
          LineItem.where(imprintable_object_id: white_shirt_m.id,
                         imprintable_object_type: 'ImprintableVariant')
        ).to exist
        expect(
          LineItem.where(imprintable_object_id: white_shirt_l.id,
                         imprintable_object_type: 'ImprintableVariant')
        ).to exist
        expect(
          LineItem.where(imprintable_object_id: white_shirt_xl.id,
                         imprintable_object_type: 'ImprintableVariant')
        ).to exist
        expect(
          LineItem.where(job_id: job.id)
        ).to exist
      end

      it 'only fires one public activity activity', activity_spec: true do
        PublicActivity.with_tracking do
          initial_size = activities.size
          post :create, format: :json,
                        job_id: job.id,
                        imprintable_id: shirt.id,
                        color_id: white.id
          expect(activities.reload.size).to eq initial_size + 1
        end
      end

      context 'and the job already has some line items' do
        before(:each) do
          job.line_items << white_shirt_m_item
          job.line_items << white_shirt_l_item
        end

        it 'fails when the job has all line items' do
          job.line_items << white_shirt_s_item
          job.line_items << white_shirt_xl_item
          post :create, format: :json,
                        job_id: job.id,
                        imprintable_id: shirt.id,
                        color_id: white.id
          json_response = JSON.parse response.body
          expect(json_response['result']).to eq 'failure'
        end
      end
    end
  end

  describe '#destroy', destroy: true do
    context 'with a 4-size imprintable line item group' do
      let!(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }
      make_variants :white, :shirt, [:S, :M, :L, :XL]

      it 'destroys them all when supplied with their ids' do
        line_items = job.line_items.to_a
        delete :destroy, format: :json, id: line_items.map(&:id).join('/')

        json_response = JSON.parse response.body
        expect(json_response['result']).to eq 'success'

        line_items.each do |line_item|
          expect(LineItem.where(id: line_item.id)).to_not exist
        end
      end

      it 'only fires one activity', activity_spec: true do
        PublicActivity.with_tracking do
          initial_size = PublicActivity::Activity.where(trackable_type: 'LineItem').size
          delete :destroy, format: :json, id: job.line_items.map(&:id).join('/')
          expect(PublicActivity::Activity.where(trackable_type: 'LineItem').size).to eq initial_size + 1
        end
      end
    end
  end

  describe '#update' do
    context 'with params in a format of line_item[id[field_name[value]]]' do
      let!(:job) { create(:job) }
      let(:order) { job.order }
      let!(:line_item_1) { create :non_imprintable_line_item, job: job }
      let!(:line_item_2) { create :non_imprintable_line_item, job: job }
      let(:id1) { line_item_1.id }
      let(:id2) { line_item_2.id }

      let(:params_hash) do
        {
          line_item: {
            id1.to_s => {
              quantity: 999,
              unit_price: 999
            },

            id2.to_s => {
              quantity: 1,
              unit_price: 1
            }
          }
        }
      end

      it 'should update the line items with the given ids' do
        put :update, params_hash

        [line_item_1, line_item_2].each(&:reload)

        expect(line_item_1.quantity).to eq 999
        expect(line_item_1.unit_price).to eq 999

        expect(line_item_2.quantity).to eq 1
        expect(line_item_2.unit_price).to eq 1
      end

      it 'does not send an email, because the order is not in production' do
        expect(OrderMailer).to_not receive(:imprintable_line_items_changed)
        put :update, params_hash
      end

      it 'does not result in any order activities being created', pa_spam: true do
        PublicActivity.with_tracking do
          expect { put :update, params_hash }.to_not change { order.activities.reload.size }
        end
      end
    end

    context 'when the order is already in production', oip: true do
      let!(:prod_order) { create(:production_order) }
      let!(:order) { create(:order_with_job, softwear_prod_id: prod_order.id) }
      let(:job) { order.jobs.first }
      let!(:line_item_1) { create :imprintable_line_item, job: job }

      let(:params_hash) do
        {
          line_item: {
            line_item_1.id.to_s => {
              quantity: 90,
              unit_price: 1
            }
          }
        }
      end

      it 'sends a notification email' do
        expect(OrderMailer).to receive(:imprintable_line_items_changed)
          .with(order, anything, anything)
          .and_return double('mail', deliver_now: true)

        put :update, params_hash
      end
    end
  end

  it_can 'batch update'

  describe '#select_options' do

    context 'when there are brands' do
      2.times { |i| let!("brand#{i}") { create(:valid_brand) } }

      it 'responds with a select tag for brands' do
        get :select_options
        expect(response.body).to include '<select'
        expect(response.body).to include brand0.name
        expect(response.body).to include brand1.name
      end

      context 'with brand_id' do
        2.times do |i|
          let!("imprintable#{i}") do
            create(:associated_imprintable, brand_id: brand1.id)
          end
        end

        context 'when there are matching styles' do
          it 'responds with a select tag for styles' do
            get :select_options, brand_id: brand1.id
            expect(response.body).to include '<select'
            expect(response.body).to include imprintable0.style_name
            expect(response.body).to include imprintable1.style_name
          end
        end
        context 'where there are no matching styles' do
          it 'responds with error message html' do
            get :select_options, brand_id: brand0.id
            expect(response.body).to include "Couldn't find"
          end
        end

        context 'with imprintable_id' do
          2.times { |i| let!("color#{i}") { create(:valid_color) } }
          2.times { |i| let!("size#{i}") { create(:valid_size) } }

          let!(:iv0) do
            create(
              :associated_imprintable_variant,
              imprintable_id: imprintable0.id,
              color_id:       color0.id
            )
          end
          2.times { |i| let!("iv1_#{i}") {
            create(
              :associated_imprintable_variant,
              imprintable_id: imprintable0.id,
              size_id:        send("size#{i}").id,
              color_id:       color1.id
          ) } }

          context 'when there are matching colors' do
            it 'responds with a select tag for colors' do
              get :select_options, imprintable_id: imprintable0.id
              expect(response.body).to include '<select'
              expect(response.body).to include color0.name
              expect(response.body).to include color1.name
            end
          end
          context 'when there are no matching colors' do
            it 'responds with error message html' do
              get :select_options, imprintable_id: imprintable1.id
              expect(response.body).to include "Couldn't find"
            end
          end

          context 'and color_id' do
            context 'when there are matching variants' do
              it 'responds with the name and description' do
                get :select_options, imprintable_id: imprintable0.id,
                                     color_id: color1.id
                expect(response.body).to include imprintable0.style_name
                expect(response.body).to include imprintable0.style_catalog_no
                expect(response.body).to include imprintable0.description
              end
            end
            context 'when there is no matching variant' do
              it 'responds with error message html' do
                get :select_options, imprintable_id: imprintable1.id,
                                     color_id: color0.id
                expect(response.body).to include "Couldn't find"
              end
            end
          end
        end
      end
    end
    context 'when there are no brands' do
      it 'responds with error message html' do
        get :select_options
        expect(response.body).to include "Couldn't find"
      end
    end
  end
end
